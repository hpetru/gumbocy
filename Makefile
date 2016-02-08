GUMBO_VERSION ?= 0.10.1

clean:
	rm -rf *.so build *.c *.html dist .cache tests/__pycache__ *.rst

cythonize:
	cython --warning-extra --annotate gumbocy.pyx

build_ext: clean cythonize
	python setup.py build_ext --inplace -Igumbo-parser/src -Lgumbo-parser/.libs -Rgumbo-parser/.libs

rst:
	pandoc --from=markdown --to=rst --output=README.rst README.md

virtualenv:
	rm -rf venv
	virtualenv venv
	venv/bin/pip install -r requirements.txt

test: build_ext
	py.test tests/ -vs

gumbo_build:
	curl -L https://github.com/google/gumbo-parser/archive/v$(GUMBO_VERSION).tar.gz > gumbo.tgz
	rm -rf gumbo-parser-$(GUMBO_VERSION) gumbo-parser
	tar zxf gumbo.tgz
	mv gumbo-parser-$(GUMBO_VERSION) gumbo-parser
	cd gumbo-parser && ./autogen.sh && ./configure && make
	rm -rf gumbo.tgz

docker_build:
	docker build -t commonsearch/gumbocy .

docker_ssh:
	docker run -v "$(PWD):/cosr/gumbocy:rw" -w /cosr/gumbocy -i -t commonsearch/gumbocy bash
