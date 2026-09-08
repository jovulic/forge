{
  lib,
  buildNpmPackage,
  fetchurl,
}:

buildNpmPackage rec {
  pname = "typescript-svelte-plugin";
  version = "0.3.52";

  src = fetchurl {
    url = "https://registry.npmjs.org/typescript-svelte-plugin/-/typescript-svelte-plugin-${version}.tgz";
    hash = "sha256-F0psKMVXJw4hSucCUtgHw/47uA0k+sbMqRdhZFTwAFo=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-FzvkZwOyWO4TWFxJ2dvgUJsAzSn/XrfDfatyy5ykw/A=";

  dontNpmBuild = true;

  meta = with lib; {
    description = "Svelte support for TypeScript tsserver plugin";
    homepage = "https://github.com/sveltejs/language-tools/tree/master/packages/typescript-plugin";
    license = licenses.mit;
  };
}
