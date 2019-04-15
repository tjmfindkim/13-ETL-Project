# 13-ETL-Project

## Project Proposal for Agustin, Jeff, and Tony ##

The overall objective for this exercise is to take a look at movies based on comic book characters to determine how the ratios of ¡°good¡±/¡°bad¡± characters effects movie revenue. This first step will focus on just the ¡°Marvel¡± characters. The ETL portion of this exercise will consist of the following steps:

E**xtract: We will pull in comic book character data from
https://www.kaggle.com/fivethirtyeight/fivethirtyeight-comic-characters-dataset and movie data from
https://www.kaggle.com/rounakbanik/the-movies-dataset.
Both datasets are obtainable in "CSV" format.

T**ransform: We start with the 538 dataset to identify just the ¡°Marvel¡± characters and determine if they are considered good or bad. The name field will need to be split to pull out just the appropriate name for later join operations.

The movies dataset contains several tables. For this exercise, we will need the credits and movies_metadata tables. The credits and movies_metadata tables can be joined on ID. We will need to split the credits cast column to pull out the character name for joining with the movies datasets. Movie revenue is included in the movies_metadata table.

L**oad: the final database, tables/collections, and why this was chosen.
We will load the datasets into a MySQL database for storage and future use since the datasets are available in a consistent format and the-movies-dataset tables already have relational keys to make future queries straight forward.