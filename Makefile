
## TODO, variables with wildcards to autogen these filenames
## Content/Fonts/Arial12.xnb
## Content/Fonts/PlayerLevelFont.xnb
## Content/Fonts/EnemyLevelFont.xnb
## Content/Fonts/GoldFont.xnb 
## and set them as proper target dependencies

all: Content

Content: Content/Fonts
	mkdir -p Content
	cp src/HeroNames.txt Content/
	cp src/HeroineNames.txt Content/

Content/Fonts:
	mkdir -p Content/Fonts
	./src/fonts/render.sh Arial12.conf
	./src/fonts/render.sh PlayerLevelFont.conf
	./src/fonts/render.sh EnemyLevelFont.conf
	./src/fonts/render.sh GoldFont.conf
	mv ./src/fonts/xnb/*.xnb Content/Fonts

# just in case, for windows or something maybe
UID?=1000

docker: docker-image
	docker run -it -e UID=$(UID) -v $(PWD):/build -w /build --rm openrl1 make docker-all

docker-image:
	docker build -t openrl1 .

docker-all: all
	chown -R $(UID):$(UID) Content
	## todo, should stop building in the fonts directory
	chown -R $(UID):$(UID) src/fonts
