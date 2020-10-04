#!/usr/bin/env python
# -*- coding: utf-8 -*-

from pathlib import Path
import numpy as np
import os
try:
  from geog0111.modis import Modis
except:
  from modis import Modis

'''
local download of MODIS datasets and storage in dbfile
'''

__author__    = "P. Lewis"
__email__     = "p.lewis@ucl.ac.uk"
__date__      = "28 Aug 2020"
__copyright__ = "Copyright 2020 P. Lewis"
__license__   = "GPLv3"

def lai(year=2019,tile=['h17v03', 'h17v04', 'h18v03', 'h18v04']):
  kwargs = {
    'tile'      :    tile,
    'product'   :    'MCD15A3H',  
    'log'       :    f'/shared/groups/jrole001/geog0111/work/lai_{year}_{tidy(tile)}_log.txt',
    'db_file'   :    ['/shared/groups/jrole001/geog0111/work/database.db'],
    'local_dir' :    '/shared/groups/jrole001/geog0111/work',
    'verbose'   :    True
  }
  modis = Modis(**kwargs)
  
  result = modis.get_data(year,step=4)
  return result

def tidy(s):
  return str(s).replace("'","").replace('"','').replace(',','_').replace('[','_').replace(']','_')

def snow(year=2019,tile=['h19v03']):
  name = f'work/snow_{year}_{tidy(tile)}'
  kwargs = {
    'tile'      :    tile,
    'product'   :    'MOD10A1',
    'log'       :    f'/shared/groups/jrole001/geog0111/work/snow_{year}_{tile}_log.txt',
    'db_file'   :    ['/shared/groups/jrole001/geog0111/work/database.db'],
    'local_dir' :    '/shared/groups/jrole001/geog0111/work',
    'verbose'   :    True
  }
  modis = Modis(**kwargs)
  retval = modis.stitch(year)

def lc(year,tile=['h17v03', 'h18v03']):
  kwargs = {
    'tile' : tile,
    'product'   :    'MCD12Q1',
    'log'       :    f'/shared/groups/jrole001/geog0111/work/lc_{year}_{tile}_log.txt',
    'db_file'   :    ['/shared/groups/jrole001/geog0111/work/database.db'],
    'local_dir' :    '/shared/groups/jrole001/geog0111/work',
    'verbose'   :    True
  }
  # get the data
  modis = Modis(**kwargs)
  # specify day of year (DOY) and year
  data_MCD12Q1 = modis.get_data(year,1)

def ba(year,tile=['h22v10']):
  kwargs = {
    'tile'      :    tile,
    'product'   :    'MCD64A1',
    'log'       :    f'/shared/groups/jrole001/geog0111/work/ba_{year}_{tile}_log.txt',
    'db_file'   :    ['/shared/groups/jrole001/geog0111/work/database.db'],
    'local_dir' :    '/shared/groups/jrole001/geog0111/work',
    'verbose'   :    True
  }
   # get the data
  modis = Modis(**kwargs)
  # specify day of year (DOY) and year
  data_MCD12Q1 = modis.get_data(year)

def main():
    for tile in ['h11v04','h12v04','h19v03','h19v04','h30v10','h31v10','h19v11','h19v10','h22v10','h23v10']:
      tile = [tile]
      for year in [2018,2019,2020]:
        try:
          lai(year,tile=tile)
        except:
          pass
        try:
          snow(year=year,tile=tile)
        except:
          pass
        try:
          lc(year,tile=tile)
        except:
          pass
        try:
          ba(year,tile=tile)
        except:
          pass


if __name__ == "__main__":
    main()

