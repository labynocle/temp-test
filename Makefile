
get-version:
	@echo v`cat version.txt`

set-version:
	@if [ -z "${NEW_VERSION}" ]; then \
                echo "Usage: make set-version NEW_VERSION=X.Y.Z" && \
                exit 1; \
        fi
	@echo "${NEW_VERSION}" | sed -e "s/^v//g" > version.txt

