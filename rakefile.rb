
namespace :build do
  task :hs => 'bin/haskell/MyMonad'
  task :ml => 'bin/ocaml/MyMonad'

  file 'bin/haskell/MyMonad' => 'src/main/haskell/MyMonad.hs' do |t|
    outdir = File.dirname(t.name)
    sh "mkdir -p #{outdir}"
    sh "ghc -o #{t.name} --outdir #{outdir} #{t.prerequisites.join ' '}"
  end

  file 'bin/ocaml/MyMonad' => 'src/main/ocaml/MyMonad.ml' do |t|
    outdir = File.dirname(t.name)
    sh "mkdir -p #{outdir}"
    sh "ocamlc -o #{t.name} #{t.prerequisites.join ' '}"
  end
end

namespace :run do
  task :hs do
    f = 'src/main/haskell/MyMonad.hs'
    sh "runhaskell #{f}"
  end

  task :ml do
    f = 'src/main/ocaml/MyMonad.ml'
    sh "ocaml #{f}"
  end
end

