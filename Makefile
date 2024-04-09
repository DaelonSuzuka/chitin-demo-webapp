# **************************************************************************** #
# General Make configuration

# This suppresses make's command echoing. This suppression produces a cleaner output. 
# If you need to see the full commands being issued by make, comment this out.
MAKEFLAGS += -s

# **************************************************************************** #
# Development Targets

# run the application
run: venv
	$(VENV_PYTHON) src/app.py --host 0.0.0.0 --debug --cmd-args "-c 'screen -R chitin-demo /dev/ttyUSB1 1000000'"

# remove the various build outputs
clean:
	-@ $(RM) build
	-@ $(RM) dist

# **************************************************************************** #
# python venv settings
VENV_NAME := .venv

ifeq ($(OS),Windows_NT)
	VENV_DIR := $(VENV_NAME)
	VENV := $(VENV_DIR)\Scripts
	PYTHON := python
	VENV_PYTHON := $(VENV)\$(PYTHON)
	VENV_PYINSTALLER := $(VENV)\pyinstaller
	RM := rd /s /q 
else
	VENV_DIR := $(VENV_NAME)
	VENV := $(VENV_DIR)/bin
	PYTHON := python3
	VENV_PYTHON := $(VENV)/$(PYTHON)
	VENV_PYINSTALLER := $(VENV)/pyinstaller
	RM := rm -rf 
endif

# Add this as a requirement to any make target that relies on the venv
.PHONY: venv
venv: $(VENV_DIR)

# Create the venv if it doesn't exist
$(VENV_DIR):
	$(PYTHON) -m venv $(VENV_DIR)
	$(VENV_PYTHON) -m pip install --upgrade pip
	$(VENV_PYTHON) -m pip install -r requirements.txt

# If the first argument is "pip"...
ifeq (pip,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "pip"
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif

# forward pip commands to the venv
pip: venv
	$(VENV_PYTHON) -m pip $(RUN_ARGS)

# update requirements.txt to match the state of the venv
freeze_reqs: venv
	$(VENV_PYTHON) -m pip freeze > requirements.txt

# try to update the venv - expirimental feature, don't rely on it
update_venv: venv
	$(VENV_PYTHON) -m pip install --upgrade -r requirements.txt

# deletes the venv
clean_venv:
	$(RM) $(VENV_DIR)

# deletes the venv and rebuilds it
reset_venv: clean_venv venv