
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

  file 'bin/cpp/my_monad' => 'src/main/cpp/my_monad.cpp' do |t|
    # cc = 'clang++ -std=c++11 -stdlib=libc++ -Weverything'
    cc = 'clang++ -std=c++11 -stdlib=libc++'
    # cc = 'g++ -std=c++0x'
    # cc = 'g++'
    outdir = File.dirname(t.name)
    sh "mkdir -p #{outdir}"
    sh "#{cc} -o #{t.name} #{t.prerequisites.join ' '}"
  end
end

namespace :run do
  task :scala do
    sh "sbt run"
  end

  task :hs do
    f = 'src/main/haskell/MyMonad.hs'
    sh "runhaskell #{f}"
  end

  task :ml do
    f = 'src/main/ocaml/MyMonad.ml'
    sh "ocaml #{f}"
  end

  task :d do
    f = 'src/main/d/MyMonad.d'
    sh "dmd -run #{f}"
  end

  task :cpp => 'bin/cpp/my_monad' do |t|
    bin = t.prerequisites[0]
    sh bin
  end

  task :rb do
    f = 'src/main/ruby/my_monad.rb'
    sh "ruby #{f}"
  end
end

