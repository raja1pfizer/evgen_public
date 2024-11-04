import configparser
import logging
import os
import pandas as pd
import snowflake.connector
import sys


# setup required directories
BASE_DIR = os.path.dirname(os.path.realpath(__file__))
DATA_DIR = os.path.join(BASE_DIR, '..', 'data')
ARCHIVE_DIR = os.path.join(DATA_DIR, 'archive')
CONFIG_DIR = os.path.join(BASE_DIR, 'config')
LOG_DIR = os.path.join(BASE_DIR, '..', 'logs')
OUTPUT_DIR = os.path.join(DATA_DIR, 'input')
QUERY_DIR = os.path.join(BASE_DIR, 'sql')

# create requried directories if they don't exist
if not os.path.isdir(ARCHIVE_DIR):
    os.makedirs(ARCHIVE_DIR)
if not os.path.isdir(LOG_DIR):
    os.makedirs(LOG_DIR)

# define required files
CONFIG_FILE = os.path.join(CONFIG_DIR, 'env.ini')
CONFIG_FILE_SECTION = 'Snowflake'
LOG_FILE = os.path.join(LOG_DIR, 'data_pulls.log')
OUTPUT_FILE = os.path.join(OUTPUT_DIR, 'EvidenceCatalog.csv')
QUERY_FILE = os.path.join(QUERY_DIR, 'KIMS_EC.sql')

# define required environment variables
REQUIRED_ENV_VARIABLES = ['BOW_DB_ACCOUNT',
                          'BOW_DB_USER',
                          'BOW_DB_USER_PASSWORD',
                          'BOW_DB_ROLE',
                          'BOW_DB_DATABASE',
                          'BOW_DB_SCHEMA',
                          'BOW_DB_WAREHOUSE']


# setup logging
logFormatter = logging.Formatter('%(asctime)s [%(threadName)-12.12s] [%(levelname)-5.5s]  %(message)s')
logger = logging.getLogger(__name__)

fileHandler = logging.FileHandler(os.path.join(LOG_DIR, LOG_FILE), mode = 'a')
fileHandler.setFormatter(logFormatter)
logger.addHandler(fileHandler)

consoleHandler = logging.StreamHandler()
consoleHandler.setFormatter(logFormatter)
logger.addHandler(consoleHandler)


# if a config file exists, read it in and set environment variables from it
if os.path.exists(CONFIG_FILE):
    config = configparser.ConfigParser()
    _ = config.read(CONFIG_FILE)
    if CONFIG_FILE_SECTION in config.sections():
        env_vars = config.items(CONFIG_FILE_SECTION)
        if len(env_vars) == 0:
            logger.warnning(f'Config file {CONFIG_FILE} has no properties defined in section {CONFIG_FILE_SECTION}.')
        else:
            for key, var in env_vars:
                os.environ[key.upper()] = var
    else:
        logger.warning(f'Config file {CONFIG_FILE} found, but has no section {CONFIG_FILE_SECTION}.')


def _validate_environment() -> None:
    """
    Desc:
        Validate that all required environment variables are set.
    Args:
        None
    Returns:
        None
    Raises:
        ValueError: if any required environment variables are missing
    """

    missing_vars = []
    for var in REQUIRED_ENV_VARIABLES:
        if var not in os.environ:
            missing_vars.append(var)
    if len(missing_vars) > 0:
        raise ValueError(f'Required environment variables are missing: {missing_vars}')
    
    return None

def _get_connection_parameters() -> dict:
    """
    Desc:
        Get the connection parameters for the Snowflake connection.
    Args:
        None
    Returns:
        dict: connection parameters
    """

    return {
        'account': os.environ.get('BOW_DB_ACCOUNT'),
        'user': os.environ.get('BOW_DB_USER'),
        'password': os.environ.get('BOW_DB_USER_PASSWORD'),
        'role': os.environ.get('BOW_DB_ROLE'),
        'database': os.environ.get('BOW_DB_DATABASE'),
        'schema': os.environ.get('BOW_DB_SCHEMA'),
        'warehouse': os.environ.get('BOW_DB_WAREHOUSE'),
        'authenticator': 'snowflake'
    }

def _get_db_connection(**conn_params: dict) -> snowflake.connector.connection:
    """
    Desc:
        Get a connection to the Snowflake database.
    Args:
        conn_params (dict): connection parameters
    Returns:
        snowflake.connector.connection: Snowflake connection
    """

    return snowflake.connector.connect(**conn_params)

def _read_sql(directory: str = None, sql_file: str = QUERY_FILE) -> str:
    """
    Desc:
        Get the SQL query from a file.
    Args:
        directory (str): directory containing the query file
        sql_file (str): query file
    Returns:
        str: SQL query
    Raises:
        FileNotFoundError: if the query file is not found
    """

    if directory is None:
        logger.warning(f'no query directory specified assuming the sql file is fully qualified')
    else:
        sql_file = os.path.join(directory, sql_file)
    
    if not os.path.isfile(sql_file):
        raise FileNotFoundError(f'Query file {sql_file} not found.')
    
    with open(sql_file, 'r') as f:
        return f.read()

def _execute_query(conn: snowflake.connector.connection, sql :str) -> pd.DataFrame:
    """
    Desc:
        Execute a SQL query and return the results as a pandas DataFrame.
    Args:
        conn (snowflake.connector.connection): Snowflake connection
        sql (str): SQL query to execute
    Returns:
        pd.DataFrame: results of the query
    """

    curs = conn.cursor()
    curs.execute(sql)
    
    return curs.fetch_pandas_all()

def run(verbose: bool = True):
    """
    Desc:
        Run the data refresh process.
    Args:
        verbose (bool): whether to run in verbose mode
    Returns:
        None
    """

    # update the logging level based on the verbose flag
    if verbose:
        logger.setLevel(logging.INFO)
    else:
        logger.setLevel(logging.WARNING)
    
    # validate the environment
    logger.info('validating the environment')
    _validate_environment()

    # get the SQL query
    logger.info('getting SQL query')
    try:
        sql = _read_sql()
    except Exception as e:
        logger.critical(f'Error getting SQL query: {e}')
        sys.exit(1)

    # establish the Snowflake connection
    logger.info('establishing Snowflake connection')
    try:
        conn = _get_db_connection(**_get_connection_parameters())
    except Exception as e:
        logger.critical(f'Error establishing Snowflake connection: {e}')
        sys.exit(1)

    # execute the query
    df = pd.DataFrame()
    try:
        logger.info('pulling results')
        df = _execute_query(conn = conn, sql = sql)
    except Exception as e:
        logger.critical(f'Error pulling data: {e}')
        sys.exit(1)

    # close the Snowflake connection
    try:
        logger.info('closing Snowflake connection')
        conn.close()
    except Exception as e:
        logging.error('unable to close Snowflake connection: {e}')

    if df.empty:
        logger.critical("No data returned from query.")
        sys.exit(1)
    
    # log the results counts
    logger.info(f'query returned {df.shape[0]} rows and {df.shape[1]} columns')

    # shuffle files and output results
    archived_file = os.path.join(ARCHIVE_DIR, f'EvidenceCatalog_{pd.Timestamp.now().strftime("%Y%m%d%H%M")}.csv')
    existing_file = OUTPUT_FILE
    moved_existing_file = False
    if not os.path.exists(existing_file):
        logger.warning(f'Existing file {existing_file} not found.')
    else:
        try:
            # move old file
            os.rename(existing_file, archived_file)
            moved_existing_file = True
        except FileNotFoundError:
            logger.critical(f'Unable to move existing file {OUTPUT_FILE} to {archived_file}.')
            sys.exit(1)

    try:
        # write out new results
        logger.info(f"Writing out new results to {existing_file}")
        df.to_csv(existing_file, index = False)
    except Exception as e:
        logger.critical(f'Error writing out new results: {e}')
        if moved_existing_file:
            try:
                os.rename(archived_file, existing_file)
            except Exception as e:
                logger.critical(f'Error moving archived file back: {e}')


    logger.info('DONE')
    logging.shutdown()

if __name__ == '__main__':
    run()
