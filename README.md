<p align="center">
  <img src="https://github.com/orxaicom/Sefaria-Desktop-Unofficial/blob/18d6058e072c6d799550557ec0537eddf483e727/assets/Sefaria-Desktop-Unofficial.png" alt="Icon of Sefaria Desktop Unofficial">
</p>

# Sefaria Desktop Unofficial

This is an **experimental** work in progress. You're welcome to test and contribute.

## Quick Start
Currently only supported on Linux.

First sign in to GitHub. Then go to
[here](https://github.com/orxaicom/Sefaria-Desktop-Unofficial/actions/runs/11199548028),
and download the AppImage (At the bottom of the page in Artifacts section).
It's around 2.8 GB.

Unzip it using `unzip` command.
Make it executable and run it:
```bash
chmod +x ./Sefaria-Desktop-Unofficial-x86_64.AppImage
./Sefaria-Desktop-Unofficial-x86_64.AppImage
```
The first time that you run it, it copies the Sefaria database and logs to
`~/Sefaria-Desktop-Unofficial`.
After that wait for a minute or two until the server is up.
When you see:
```
Starting development server at http://127.0.0.1:8000/
Quit the server with CONTROL-C.
```
Open your browser and go to `http://127.0.0.1:8000/`

## NOTES
This repository packages
[Sefaria-Project](https://github.com/Sefaria/Sefaria-Project) which contains the
source code for the Sefaria website, and all its dependencies including:
* python3.8 and its packages
* node modules
* MongoDB
* Redis server
* Restored [Sefaria database](https://storage.googleapis.com/sefaria-mongo-backup/dump_small.tar.gz)

and some other required binaries and their libraries into a self contained AppImage.
It's an executable that doesn't have any dependencies to run on a Linux system
(Other than `FUSE` that AppImage needs to let non-root users mount filesystems, It's
available on most systems, except on docker. You can run it like this if `FUSE` not
available: `Sefaria-Desktop-Unofficial-x86_64.AppImage --appimage-extract-and-run`).
It depends on our other repository,
[Sefaria-Container-Unofficial](https://github.com/orxaicom/Sefaria-Container-Unofficial)
which is a docker container that has Sefaria installed in it.

Now that we have a working AppImage it's trivial to wrap it inside an electron
app that displays the port 8000. In fact I've done that and build the electron
for Linux (I've lost the working version on my disk, have to write it again).
At the moment I don't use Windows or Mac and haven't build for them or test on them.

Please open an issue if you've encountered any errors when running this program.
All suggestions and PRs are appreciated.

This project is meant to assemble a team of volunteers to work on this
until we have a working desktop app for Windows, Mac and Linux, as it's been
[long overdue](https://github.com/Sefaria/Sefaria-Project/issues/294).

## TODO
* [ ] Check for any web request to internet (for example web fonts) and pack those
      in the AppImage to make it fully self contained.
* [ ] I've tried to upload the AppImage to the GitHub Releases, But it doesn't allow
      files larger than 2 GB.
* [ ] The start up time for the server is around 2 minutes and unacceptable. Profile
      it to see why it takes so long. Investigate using Gunicorn. Also tried
      manage.py runserver --skip-checks but since we're shipping with an older
      version of django, it's not supported.
* [ ] Currently we're packaging python3.8 with the AppImage per
      [Sefaria's Recommendation](https://developers.sefaria.org/docs/local-installation-instructions).
      Work with Sefaria to fix the bugs and move to a recent version.
* [ ] MongoDB needs to write to the database directory, for journaling and what not.
      That's the reason we first
      [write the database](https://github.com/orxaicom/Sefaria-Desktop-Unofficial/blob/5533ca05742485437f6268373ce7544b3ab07f08/assets/AppRun#L22)
      to `~/Sefaria-Desktop-Unofficial`. But since we're using the db readonly,
      this is not an elegant solution, ideally the db should stay in the AppImage.
      I think recent versions of MongoDB
      [removed](https://www.mongodb.com/docs/v4.4/tutorial/manage-journaling/)
      the `--nojournal` option.
* [ ] Should we have a GUI or just ship this as a server?
* [ ] If some Windows users experiment with running this on WSL, that would be intersting.
      Mac people as well.
* [ ] See whether we can query the api locally like
      [this](https://developers.sefaria.org/reference/getting-started-with-your-api)
* [ ] [This](https://docs.appimage.org/packaging-guide/distribution.html) contains
      great guidelines for making a professional AppImage, abide by them.
* [ ] Investigate the copyright implications of bundling binaries with AppImages.
