all: build

build:
	@docker build . --tag=allir/squid
