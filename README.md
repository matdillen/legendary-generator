# legendary-generator

## Requirements

[Install R](https://www.r-project.org/).

(optional) [Buy Tabletop Simulator[(https://www.tabletopsimulator.com/).

## Introduction
This is a Shiny R app in development to generate setups for the Marvel Legendary deck-building game by [Upper Deck](https://upperdeckstore.com/games-collectibles/legendary.html). The `app.R` file can be run from an R IDE such as [RStudio](https://rstudio.com/). You can also modify `run.bat` with notepad to point to your R installation and `run.R` to point to the directory where this repository was downloaded to. Then executing `run.bat` will load the app in the default browser, provided the required R packages are installed (which should happen automatically if not).

The app is designed to generate multiple setups with each run, depending on all the input parameters. The default is 100, but 1 up to 1.000 is possible. Choosing preferential sets may diminish the setup count, possibly to 0. Some combinations of preferences will not be possible. The following options are currently supported:

- Setting preferential cards to be included.
- Visualizing text dumps of card text. Card texts have been taken from the [wiki](https://www.boardgamegeek.com/wiki/page/Legendary_Marvel_Complete_Card_Text) on Boardgamegeek. The markdown and style of the text may still have issues in some cases.
- Adjusting the number of setups generated with each run.
- Excluding certain expansions.
- Including a minimum set of cards from certain preferential expansions.
- Toggling the possibility of epic masterminds. **This function still has some problems.**
- Calculating certain metrics for the setup. This includes indicators for wound frequency, probability of escaping villains, deficits for hero colors and more. However, **their reliability and interpretation is still under development.**
- Adjusting player count from 2 to 5. Playing solo by the book is not supported. For solo play, playing two hands is recommended.
- Looking up the rules text of certain keywords and other mechanics. Keyword info taken from https://marveldbg.wordpress.com/ .

All Marvel Legendary cards released up to this date (2020-17-07) should be present, bar a few promotional cards and cards added in MCU Phase 1 and other game rereleases. Errors in transcription may be present. Unessential information such as individual hero card names or mastermind tactics names may not be fully or correctly transcribed.

## Exports

A generated setup can be easily copied to clipboard for keeping track of setup outcomes in a spreadsheet. An example sheet with some results can be found in `results.xlsx` under `support`.

In the `support` folder, zipped save files based on a [scripted Tabletop Simulator mod](https://steamcommunity.com/sharedfiles/filedetails/?id=1777582863) can be found. These save files include some modifications to enable import from a setup exported by this app. A button for export of a setup to Tabletop Simulator is present in the app. The setup can then be pasted in the text input field in Tabletop Simulator (select the text input field and use `CTRL + V`). A few schemes may not be scripted properly yet and there may be other bugs.

To import a saved game, unzip the file and copy it to `Documents\My Games\Tabletop Simulator\Saves`.
