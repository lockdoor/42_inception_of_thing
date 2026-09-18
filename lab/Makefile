VAGRANT=$(shell if command -v vagrant 2>/dev/null; then echo 'vagrant'; else echo 'vagrant.exe'; fi)

all:
	$(VAGRANT) -v

up:
	$(VAGRANT) up

halt:
	$(VAGRANT) halt

destroy:
	$(VAGRANT) destroy -f
	rm -rf ./vagrant

clean: halt destroy

re: clean up