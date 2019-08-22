Gem::Specification.new do |gspec|
	gspec.name = "etblog"
	gspec.version = "0.1.1"
	gspec.authors = [ "Tim K" ]
	gspec.date = "2019-08-22"
	gspec.description = "A really tiny static blog generator written in Ruby."
	gspec.license = "MIT"
	gspec.email = "timprogrammer@rambler.ru"
	gspec.executables = [ "etblog" ]
	gspec.files = [ "lib/etblog.rb", "lib/index-default-etblog.html", "bin/etblog" ]
	gspec.has_rdoc = false
	gspec.homepage = "http://timkoi.gitlab.io/etblog"
	gspec.summary = gspec.description.clone
end
