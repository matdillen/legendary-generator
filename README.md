# legendary-generator
 
A Shiny R app in development to generate setups for the Marvel Legendary deck-building game by [Upper Deck](https://upperdeckstore.com/games-collectibles/legendary.html). The `app.R` file can be run from an R IDE such as [RStudio](https://rstudio.com/). You can also modify `run.bat` to point to your R installation and `run.R` to point to the directory where this repository was downloaded to. Then executing `run.bat` will load the app in the default browser, provided the required R packages are installed.

All Marvel Legendary cards released up to this date (2020-17-07) should be present, bar a few promotional cards and cards added in MCU Phase 1 and other game rereleases. Errors in transcription may be present. Unessential information such as individual hero card names or mastermind tactics names may not be fully or correctly transcribed.

The app is designed to generate multiple setups with each run, depending on all the input parameters. The default is 100, but 1 up to 1.000 is possible. Choosing preferential sets may diminish the setup count, possibly to 0. The following options are currently supported:

- Setting preferential cards to be included.
- Visualizing text dumps of card text. Card texts have been taken from the [wiki](https://www.boardgamegeek.com/wiki/page/Legendary_Marvel_Complete_Card_Text) on Boardgamegeek. The markdown and style of the text may still have issues in some cases.
- Adjusting the number of setups generated with each run.
- Excluding certain expansions.
- Including a minimum set of cards from certain preferential expansions.
- Toggling the possibility of epic masterminds.
- Calculating certain metrics for the setup. This includes indicators for wound frequency, probability of escaping villains, deficits for hero colors and more. However, their reliability and interpretation is still under development.
- Adjusting player count. Playing solo by the book is not supported and 5 players has been known to throw errors. For solo play, playing two hands is recommended.

A generated setup can be easily copied to clipboard for keeping track of setup outcomes in a spreadsheet. An example sheet with some results can be found in `results.xlsx` under `support`.

Also in `support`, `box organization.xlsx` contains a list of keywords with brief explanations, printable on a double-sides sheet. It also contains a few card errata instances and a schematic view of my own box setup.

`data` contains the csv files used and their source xlsx files, which have been designed for easy data addition and also contain field metadata used in the metrics. Also present are the csv files containing the card text.

