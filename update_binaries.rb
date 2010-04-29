#!/usr/bin/ruby

# require
require 'rubygems'
require 'net/github-upload' #sudo gem install net-github-upload

DEBUG = false
UPLOAD = false

# setup
login = `git config github.user`.chomp  # your login for github
token = `git config github.token`.chomp # your token for github
repos = 'earthvis'                    # your repos name (like 'taberareloo')
gh = Net::GitHub::Upload.new(
  :login => login,
  :token => token
)

all_os = { :linux => "Linux", :macosx => "Mac OS X (32bit)", :windows => "Windows"}

def exec(command)
 # puts command
  system(command) unless DEBUG
end

all_os.each do |os, human_os|
  file = "#{repos}_#{os}.zip"

  # rename
  next unless exec "mv application.#{os} #{repos}"

  #remove source
  exec "rm -rf #{repos}/source"
  
  if( os == :macosx )  #patch Mac Os X file to use java 1.6
      #exec "mv #{repos}/#{repos}.app/Contents/Info.plist #{repos}/#{repos}.app/Contents/Info_old.plist"
      #exec "sed 's/1\\\.5/1\\\.6/g' #{repos}/#{repos}.app/Contents/Info_old.plist > #{repos}/#{repos}.app/Contents/Info.plist"
      # copy icon
      #exec "cp -f sketch.icns #{repos}/#{repos}.app/Contents/Resources/sketch.icns"
  end 
  
  exec "cp earthvis.rdb #{repos}/"
  exec "cp earthvis.sql #{repos}/"
  exec "cp import_mysql.sh #{repos}/"
    
  #zip file
  exec "zip -x .DS_Store -r #{file} #{repos}/"
      
  #if UPLOAD
  #  direct_link =  gh.replace( :repos => repos, :file  => file, :description => "InstantsFun.Es Launchpad Wrapper #{human_os}")
  #  exec "rm #{file}"
  #end
  
  exec "rm -rf #{repos}"
  
  puts "########################  #{human_os} done ########################"  
end