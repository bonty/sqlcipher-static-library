namespace :openssl do
  namespace :ios do
    task :config do
      $project = "openssl.xcodeproj"
      $target = "crypto"
      $config = "Release"
      $sdks = %w(iphonesimulator iphoneos)
      $output_lib = 'build/ios-libs'
    end

    task build: :config do
      $sdks.each do |sdk|
        sh "xcodebuild -project #{$project} -configuration #{$config} -sdk #{sdk} -target #{$target} TARGET_BUILD_DIR=../build/#{$config}-#{sdk} BUILD_PRODUCTS_DIR=../build/#{$config}-#{sdk} clean build"
      end
    end

    task combine: :config do
      Dir.mkdir($output_lib) if !Dir.exist?($output_lib)
      Dir.glob("build/#{$config}-#{$sdks.first}/libcrypto.a") do |path|
        libfile = File.basename(path)
        libs = $sdks.map{ |s| "'build/#{$config}-#{s}/#{libfile}'" }.join(" ")
        sh "lipo #{libs} -create -output '#{$output_lib}/#{libfile}'"
      end
    end

    task :all do
      Rake::Task['openssl:ios:build'].invoke
      Rake::Task['openssl:ios:combine'].invoke
    end
  end
end

namespace :sqlcipher do
  namespace :ios do
    task :config do
      $project = "sqlcipher/sqlcipher.xcodeproj"
      $target = "sqlcipher"
      $config = "Release"
      $sdks = %w(iphonesimulator iphoneos)
      $output_lib = 'build/ios-libs'
    end

    task build: :config do
      # prepare sqlite3.c
      sh 'cd sqlcipher && make clean && ./configure --enable-tempstore=yes --with-crypto-lib=commoncrypto CFLAGS="-DSQLITE_HAS_CODEC -DSQLITE_TEMP_STORE=2" && make sqlite3.c'

      $sdks.each do |sdk|
        sh "xcodebuild -project #{$project} -configuration #{$config} -sdk #{sdk} -target #{$target} TARGET_BUILD_DIR=../build/#{$config}-#{sdk} BUILD_PRODUCTS_DIR=../build/#{$config}-#{sdk} clean build"
      end

      # clean build directory
      sh "rm -fr sqlcipher/build"
    end

    task combine: :config do
      Dir.mkdir($output_lib) if !Dir.exist?($output_lib)
      Dir.glob("build/#{$config}-#{$sdks.first}/libsqlcipher.a") do |path|
        libfile = File.basename(path)
        libs = $sdks.map{ |s| "'build/#{$config}-#{s}/#{libfile}'" }.join(" ")
        sh "lipo #{libs} -create -output '#{$output_lib}/#{libfile}'"
      end
    end

    task :all do
      Rake::Task['sqlcipher:ios:build'].invoke
      Rake::Task['sqlcipher:ios:combine'].invoke
    end
  end
end

namespace :build do
  namespace :ios do
    Rake::Task['openssl:ios:all'].invoke
    Rake::Task['sqlcipher:ios:all'].invoke
  end
end
