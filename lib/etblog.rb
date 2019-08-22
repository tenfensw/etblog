#!/usr/bin/env ruby
# etblog.rb - Extremely Tiny Blog
require 'plist'
require 'kramdown'
require 'fileutils'

def maplists(list1, list2)
	hash = {}
	index2 = -1
	list1.each do |item|
		index2 += 1
		hash[item] = list2[index2]
	end
	return hash
end

class String
	def unxml
		inside_tag = false
		out = ''
		self.split('').each do |item|
			if item == '<' then
				inside_tag = true
			elsif item == '>' then 
				inside_tag = false
			elsif inside_tag == false then
				out += item
			end
		end
		return out
	end
end

class ETBlogCore
	def initialize(folder)
		if not File.directory? folder then
			raise 'No such directory - ' + folder
		end
		@base = folder.clone
		@output = @base + '/htdocs'
		@conf = @base + '/blog.plist'
		if not File.exists? @conf then
			File.write(@conf, { 'Title' => 'Blog', 
					    'Author' => ENV['USER'] || 'You', 
					    'Static' => 'static',
					    'Description' => 'Your new ETBlog blog.'}.to_plist )
		end
		plist_parsed = Plist.parse_xml(@conf)
		@title = plist_parsed['Title']
		@author = plist_parsed['Author']
		@static = @base + '/' + plist_parsed['Static'].to_s
		@description = plist_parsed['Description'] || 'Your new ETBlog blog.'
		@description += '<br><p>Powered by <a href="http://timkoi.gitlab.io/etblog">ETBlog</a>.</p>'
		if not File.directory? @static then
			FileUtils.mkdir_p(@static)
		end
		@links = []
		plist_parsed.keys.each do |key|
			if not ['Title', 'Author', 'Static', 'Description'].include? key then
				@links.push("<li><a href=\"#{plist_parsed[key]}\">#{key}</a></li>")
			end
		end
		if @links.length < 1 then
			@links.push("<li><a href=\"http://timkoi.gitlab.io/etblog\">ETBlog homepage</a></li>")
			@links.push("<li><a href=\"http://github.com/timkoi\">@timkoi on GitHub</a></li>")
		end
	end
	
	def conv(string, put_ctnt)
		return string.to_s.gsub('@{post}', put_ctnt).gsub('@{title}', @title).gsub('@{description}', @description).gsub('@{links}', '<ul>' + @links.join("") + '</ul>').gsub('@{author}', @author).gsub("@{year}", Time.now.year.to_s)
	end
	
	def build
		if not File.exists? @base + '/index.html' then
			FileUtils.cp(File.absolute_path(File.dirname(__FILE__)) + '/index-default-etblog.html', @base + '/index.html')
		end
		newest_post = ''
		all_posts = Dir.glob(@base + '/post-*.md').sort_by{ |f| File.mtime(f) }.reverse
		all_posts_headings = []
		all_posts_outputs = []
		ctnt_homepage = ''
		file_first = true
		all_posts.each do |item|
			output = '/posts/' + File.basename(item) + '/index.html'
			all_posts_outputs.push(output.clone)
			output = @static + output
			if not File.directory? File.dirname(output) then
				FileUtils.mkdir_p(File.dirname(output))
			end
			FileUtils.cp(@base + '/index.html', output)
			ctnt = File.read(output)
			put_ctnt = File.read(item)
			heading = Kramdown::Document.new(put_ctnt.gsub("\r\n", "\n").split("\n")[0]).to_html.unxml
			all_posts_headings.push(heading)
			put_ctnt = "<p><a href=\"../../index.html\">< Back to the homepage</a></p><br>" + Kramdown::Document.new(put_ctnt).to_html
			ctnt = self.conv(ctnt, put_ctnt)
			File.write(output, ctnt)
			puts "#{item} => #{output}"
			if newest_post == '' || File.mtime(newest_post) < File.mtime(item) then
				newest_post = item
			end
		end
		ctnt_for_main = ''
		maplists(all_posts_headings, all_posts).each do |key, value|
			ctnt_for_main += "<h2><a href=\"posts/#{File.basename(value)}/index.html\">#{key}</a></h2>"
			ctnt_for_main += "<p><i style=\"color: darkgrey;\">Posted on #{File.mtime(value).to_s} by #{@author}</i></p>"
			ctnt_for_main += "<hr>"
		end
		if ctnt_for_main == '' then
			ctnt_for_main = 'Nothing was posted on this blog yet. Stay tuned!'
		end
		File.write(@static + '/index.html', self.conv(File.read(@base + '/index.html'), ctnt_for_main))
	end
end

