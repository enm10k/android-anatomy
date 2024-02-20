.PHONY: open_android fmt pigeon provider pb all

ifeq ($(CI), true)
    FLUTTER=flutter
else
    FLUTTER=fvm flutter
endif

open_android:
	open -a /Applications/Android\ Studio.app android

fmt:
	fvm dart fix --apply lib
	fvm dart fix --apply lib
	ktlint -F android/app/src/main/kotlin/com/enm10k/anatomy/MainActivity.kt 

pb:
	scripts/pb.sh

pigeon:
	$(FLUTTER) pub run pigeon --input lib/pigeon/scheme.dart

provider:
	$(FLUTTER) pub run build_runner build --delete-conflicting-outputs

all: pb pigeon provider
