docs:
	jazzy \
	--clean \
	--exclude Tests \
	--author "Przemyslaw Bobak" \
	--author_url "https://github.com/bobek-balinek" \
	--github_url "https://github.com/bobek-balinek/BlueJet"
lint:
	swiftlint
clean:
	rm -rf ./.build
test:
	swift test
