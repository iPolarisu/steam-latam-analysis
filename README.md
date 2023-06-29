# Steam Latam Users Analysis

Big data project, includes both the scripts used to obtain the data and the scripts used to query the dataset.

## Disclaimer

This dataset was generated purely for research purposes and is not endorsed or supported by Steam or Valve Corporation. The dataset was created in compliance with the Steam API terms of use, utilizing publicly available data at the time of execution. The information contained in this dataset is provided "as is" without any representations or warranties, express or implied. The creators of this dataset do not guarantee the accuracy, completeness, or reliability of the information. Any reliance you place on such information is therefore strictly at your own risk. The creators of this dataset shall not be liable for any loss or damage arising from the use of the dataset. Please note that the dataset may not reflect the most current data or changes made by Steam or its users. Users of this dataset are advised to refer to the official Steam website and API documentation for the latest and most accurate information.

## Description

An extensive analysis of a large-scale Steam dataset has been conducted, focusing on Latin American users and their social connections (friends) using Apache Pig. For detailed insights and findings, please visit the project's [website](https://ipolarisu.github.io/steam-latam-analysis/).

## Getting Started

### Dependencies

* Linux/Windows
* A SteamAPI key (if you want to get the data by yourself)
* An internet connection
* Some time to spare
* A cluster (or maybe just a machine with Apache Pig)

### Installing

You only need to install Apache Pig to run the query script. If you want to run the experiment by yourself, install the python modules.

#### Python Modules

We highly advise you use a virtual environment for this.

1. Clone this repository
2. Install the necessary modules via pip

```bash
    pip install -r requirements.txt
```

### Executing program

#### Querying the dataset

1. Copy both the `friends.csv` and the `user-info*.csv` files to a desired location.
2. Change the respective PATHs in `steam_latam.pig`.
3. Change the store PATHs in `steam_latam.pig`.
4. Run the script using pig

    ```bash
    pig steam_latam.pig
    ```

Please make sure to use the correct PATHs so the execution does not fail.

#### Obtaining the dataset

1. Execute /steam_ladder_data/steam_ladder_scraper.py to retrieve the IDs of the SteamLadder users with the highest number of friends.
2. Replace the API key in /steam_latam_data/steam_api.py with your own.
3. Run /steam_latam_data/steam_friends.py to gather the friends' list for the users obtained from SteamLadder.
4. Execute /steam_latam_data/steam_users.py to collect the data from the friends of the SteamLadder users.
5. Run /steam_latam_data/steam_most_friends_users_info.py to obtain the information of the SteamLadder users with the most friends.

## Help

If you have any issues running the script, please feel free to open an issue or contact us, we might update the code with some bash utilities to make the setup easier.

## Authors

* [@iPolarisu](https://github.com/iPolarisu)
* [@ccarrions](https://github.com/ccarrions)
* [@AlexReisM01](https://github.com/AlexReisM01)

## License

This project is licensed under the GNU GPL v3 License - see the LICENSE.md file for details
