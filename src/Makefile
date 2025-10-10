
## TODO, variables with wildcards to autogen these filenames
## Content/Fonts/Arial12.xnb
## Content/Fonts/PlayerLevelFont.xnb
## Content/Fonts/EnemyLevelFont.xnb
## Content/Fonts/GoldFont.xnb 
## and set them as proper target dependencies

all: Content

Content: Content/Fonts
	mkdir -p Content

Content/Fonts:
	mkdir -p Content/Fonts
	./fonts/render.sh Arial12.conf
	./fonts/render.sh PlayerLevelFont.conf
	./fonts/render.sh EnemyLevelFont.conf
	./fonts/render.sh GoldFont.conf
	mv ./fonts/xnb/*.xnb Content/Fonts

# just in case, for windows or something maybe
UID?=1000

docker: docker-image
	docker run -it -e UID=$(UID) -v $(PWD):/build -w /build --rm openrl1 make docker-all

docker-image:
	docker build -t openrl1 .

docker-all: all
	chown -R $(UID):$(UID) Content
	## todo, should stop building in the fonts directory
	chown -R $(UID):$(UID) fonts
