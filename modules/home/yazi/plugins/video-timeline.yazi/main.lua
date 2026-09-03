-- video-timeline.yazi

local M = {}

local SCRIPT = os.getenv("HOME") .. "/.config/yazi/plugins/video-timeline.yazi/preview.sh"

-- Tuning knobs
local SLICE = 8             -- offsets: 0..7
local TICK_SECONDS = 1.8    -- slideshow speed
local READ_TIMEOUT_MS = 500 -- child read timeout
local META_LINES = 16       -- bottom pane height in terminal rows

-- Instant Lua-based memory cache to eliminate shell-spawn latencies and
-- rendering flicker.
local cache_paths = {}
local cache_meta = {}

-- --- helpers ---------------------------------------------------------------

local function clamp_int(n, lo, hi)
	n = tonumber(n) or 0
	if n < lo then
		return lo
	end
	if n > hi then
		return hi
	end
	return n
end

local function normalize_offset(skip)
	-- convert any numeric skip into 0..SLICE-1
	local o = tonumber(skip) or 0
	if o < 0 then
		o = 0
	end
	return o % SLICE
end

local function strip_ansi(s)
	s = s:gsub("\27%[[%;%d]*m", "")
	s = s:gsub("\27%[[%;%d]*K", "")
	s = s:gsub("\27%[[%;%d]*%G", "")
	return s
end

local function split_top_bottom(area, bottom_rows)
	-- Keep a fixed-height metadata area at the bottom so layout is stable.
	local x, y, w, h = area.x, area.y, area.w, area.h
	bottom_rows = clamp_int(bottom_rows or META_LINES, 6, math.max(6, h - 2))

	local top = ui.Rect({ x = x, y = y, w = w, h = h - bottom_rows })
	local bottom = ui.Rect({ x = x, y = y + (h - bottom_rows), w = w, h = bottom_rows })
	return top, bottom
end

local function centered_msg_rect(area, msg_len)
	return ui.Rect({
		x = area.x + math.floor(area.w / 2) - math.floor(msg_len / 2),
		y = area.y + math.floor(area.h / 2),
		w = area.w,
		h = 1,
	})
end

local function show_status(job, area, msg)
	local r = centered_msg_rect(area, #msg)
	ya.preview_widget(job, { ui.Text(msg):area(r) })
end

local function spawn_preview(path, offset, top_area)
	-- preview.sh supports extra args; it can ignore them.
	local args = {
		"--path",
		path,
		"--offset",
		tostring(offset),
		"--topw",
		tostring(top_area.w),
		"--toph",
		tostring(top_area.h),
	}

	return Command(SCRIPT):arg(args):stdout(Command.PIPED):stderr(Command.PIPED):spawn()
end

local function parse_image_marker(line)
	-- Expected: "__preview__image__path__ /some/path\n"
	if not line:match("^__preview__image__path__") then
		return nil
	end
	return line:match("^__preview__image__path__ (.+)\n")
end

local function should_keep_text(line)
	if line:len() <= 1 then
		return false
	end
	if line:match("^__") then
		return false
	end
	return true
end

local function read_child_output(job, child, top_area, bottom_area)
	-- Reads the entire child output, but caps stored metadata lines to
	-- bottom_area.h
	local meta, errs = {}, {}
	local resolved_img = nil

	while true do
		local line, event = child:read_line_with({ timeout = READ_TIMEOUT_MS })

		if event == 3 then
			-- timeout
			show_status(job, bottom_area, "Loading...")
		elseif event == 2 then
			-- EOF
			break
		elseif event == 1 then
			-- stderr
			table.insert(errs, strip_ansi(line))
		elseif event == 0 then
			-- stdout
			local img = parse_image_marker(line)
			if img then
				resolved_img = img
				ya.image_show(Url(img), top_area)
			else
				if should_keep_text(line) and #meta < bottom_area.h then
					table.insert(meta, strip_ansi(line))
				end
			end
		end
	end

	child:start_kill()
	return errs, meta, resolved_img
end

local function render_text(job, area, errs, meta)
	local out = table.concat(errs, "") .. table.concat(meta, "")
	ya.preview_widget(job, { ui.Text(out):area(area) })
end

-- --- yazi hooks ------------------------------------------------------------

function M:peek(job)
	local file = job.file
	local area = job.area

	local top, bottom = split_top_bottom(area, META_LINES)

	local offset = normalize_offset(job.skip)
	local file_url = tostring(file.url)

	-- We run a continuous, non-blocking coroutine animation loop inside this
	-- single peek job execution. Because the loop never exits, Yazi's core
	-- engine never triggers a 'clear canvas' redraw cycle. Each new frame is
	-- rendered directly on top of (replacing) the previous frame, giving a
	-- smoother video preview. If the user moves their cursor, Yazi's async
	-- runtime will instantly and cleanly cancel this loop.
	while true do
		local key = file_url .. "|" .. tostring(offset)
		local cached_img = cache_paths[key]
		local cached_meta = cache_meta[file_url]

		if cached_img and cached_meta then
			ya.image_show(Url(cached_img), top)
			render_text(job, bottom, {}, cached_meta)
		else
			local child = spawn_preview(file_url, offset, top)
			if child then
				local errs, meta, resolved_img = read_child_output(job, child, top, bottom)
				render_text(job, bottom, errs, meta)

				if resolved_img then
					cache_paths[key] = resolved_img
				end
				if #meta > 0 then
					cache_meta[file_url] = meta
				end
			end
		end

		-- Yield control back to Yazi's async executor for 1.8 seconds. This is
		-- non-blocking and so keeps the file manager responsive.
		ya.sleep(TICK_SECONDS)

		-- Advance frame offset
		offset = (offset + 1) % SLICE
	end
end

function M:seek(job)
	-- Scrub-like behavior: only re-peek if the same file is still hovered.
	local h = cx.active.current.hovered
	if not (h and h.url == job.file.url) then
		return
	end

	local next_skip = (tonumber(job.skip) or 0) + (tonumber(job.units) or 0)
	if next_skip < 0 then
		next_skip = 0
	end

	ya.emit("peek", {
		tostring(next_skip),
		only_if = tostring(job.file.url),
	})
end

return M
