# legendary-generator
 
An R script in development to generate setups for the Marvel Legendary deck-building game by [Upper Deck](https://upperdeckstore.com/games-collectibles/legendary.html). Can be used from any R IDE and can be ported to e.g. Google Colab for mobile use (updated notebook to be added soon).

`legscript.Rmd` uses digitized card info to generate setups. A few helper functions are available.

`metrics.Rmd` offers a starting point for automatically analyzing setups in terms of how easy or hard they will be, based on metrics listed in the source files for each card. Some metrics can be generated and compared.

`box organization.xlsx` contains a list of keywords with brief explanations, printable on a double-sides sheet. It also contains a few card errata instances and a schematic view of my own box setup.

`results.xlsx` offers a template for keeping track of games played and their outcome. These can be used for evaluation of the metrics generated.

`data` contains the csv files used and their source xlsx files, which have been designed for easy data addition and also contain field metadata.

In `ledgen`, a shiny app can be found with a user interface. Metrics functionality will also be better supported there. The app is still under development and some functions may not be supported yet or be buggy.

All Marvel Legendary cards released up to this date (2020-17-07) should be present, bar a few promotional cards and cards added in MCU Phase 1 and other game rereleases. Errors in transcription may be present. 
