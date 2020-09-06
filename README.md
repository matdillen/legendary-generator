# legendary-generator

## Requirements

[Install R](https://www.r-project.org/).

(optional) [Buy Tabletop Simulator](https://www.tabletopsimulator.com/).

## Introduction
This is a Shiny R app in development to generate setups for the Marvel Legendary deck-building game by [Upper Deck](https://upperdeckstore.com/games-collectibles/legendary.html). The `app.R` file can be run from an R IDE such as [RStudio](https://rstudio.com/). You can also modify `run.bat` with notepad to point to your R installation and `run.R` to point to the directory where this repository was downloaded to. Then executing `run.bat` will load the app in the default browser, provided the required R packages are installed (which should happen automatically if not).

The app is designed to generate multiple setups with each run, depending on all the input parameters. All Marvel Legendary cards released up to this date (2020-17-07) should be present, bar a few promotional cards and cards added in MCU Phase 1 and other game rereleases.

## How to use

Once the app is launched, various parameters can be set.

- Number of Players: Between 2 and 5. When playing on your own, playing two-hand solo is recommended.
- Presets?: Clicking opens up the option to set preferential schemes, masterminds, etc. It also allows the user to view the text of these cards before generating setups by selecting a card and pressing `Text`.
- Paste: A previous setup can be pasted from the clipboard this way into the preset fields. This can be useful to review the metrics of a previous game. See `results.xlsx` under `support` to see the proper format to copy.
- Sets exluded: Cards from excluded sets will not be taken into consideration for setup generation.
- Epic?: Make it possible for the generator to suggest setups with an Epic Mastermind (and his scores, for metrics purposes).
- Solo?: If set, multiplayer schemes requiring some player interaction such as `The Traitor` will not be suggested. Set by default.
- Sets included (+ Min. value): After generating setups, only those with at least a number of card groups equal to the Min. value from the desired sets will be presented. **When the Min. value is too high or the setup count too low, this function may generate zero setups.** This function is useful when you want to preferentially include cards from sets recently acquired.
- Start: The app will generate a number of random setups equal to the value for `# runs`. Default is 100, but 1 up to 1.000 is possible. It will take any of the previous parameters into account.
- Keyword info: A list of keywords and other mechanics. Selecting one generates a popup with rules text.

- Selected setup: After start has been launched and processing is complete, a slidebar will appear allowing to switch between the different setups, which will be presented on the right.
- Setup: Required cards will be listed on the right side. Hero card names are disambiguated with an id for the set they were printed in. Additional settings for special schemes may be listed at the bottom. Clicking on a cell will generate a popup with the text for this card (group).
- Copy setup: The information of the setup will be copied to clipboard in a tab-separated style. This format can be easily pasted in programs like Excel or Google Sheets, to keep track of your game results. See `results.xlsx` under `support` for an example.
- Copy to TS: This button will copy the setup in a format suitable for a mod in Tabletop Simulator. Latest version can be found as a zipped file under `support`. For more info, see below.
- Get metrics: This function will generate some analytical metrics for all setups currently generated. Potentially problematic values will be listed in red. **The reliability and interpretation of these metrics is still under development.**

## Exports and Tabletop Simulator support

A generated setup can be easily copied to clipboard for keeping track of setup outcomes in a spreadsheet. An example sheet with some results can be found in `results.xlsx` under `support`.

In the `support` folder, zipped save files based on a [scripted Tabletop Simulator mod](https://steamcommunity.com/sharedfiles/filedetails/?id=1777582863) can be found. These save files include some modifications to enable import from a setup exported by this app. A button for export of a setup to Tabletop Simulator is present in the app. The setup can then be pasted in the text input field in Tabletop Simulator (select the text input field and use `CTRL + V`). Almost all schemes should be scripted now, except for a few city-modifying setups.

To import a saved game, unzip the file and copy it to `Documents\My Games\Tabletop Simulator\Saves`.
