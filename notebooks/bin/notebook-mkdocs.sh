#!/bin/bash

# shell to sort nb
# documentation
# run bin/notebook-run.sh


here=$(pwd)
base="$(cd $(dirname "$0") &&  cd .. &&  pwd -P && cd "$here")"
repo=$(echo $base | awk -F/ '{print $NF}')

cd $base
here=$base
echo "----> running $0 from $here"
echo "--> location: $base"
echo "--> repo: $repo"

# HOME may not be set on windows
if [ -z "$HOME" ] ; then
  cd ~
  HOME=$(pwd)
  echo "--> HOME $HOME"
  cd "$base"
fi

cd "$base"

echo "--> re-making docs"
rm -rf docs
mkdir -p docs

#
# get the theme from config/mkdocs.yml
# and update ${base}/config/requirements.txt
#
theme=$(grep 'name:' config/mkdocs.yml | grep -v '#' | tail -1 | awk '{print $NF}' | sed 's/'\''//g' | sed 's/'\"'//g')
echo "theme: $theme"
grep -v $theme ${base}/config/requirements.txt > tmp.$$; mv tmp.$$  ${base}/config/requirements.txt; 
extras=$(grep $theme config/mkdocs.yml | awk '{print "mkdocs-"$NF}' | sed 's/://g' | sed 's/'\''//g' | sed 's/'\"'//g' )
echo "installing $extras"
echo $extras | awk '{for(i=1;i<=NF;i++)x[$i]=$i} END{for(i in x)print i}'  >> ${base}/config/requirements.txt

pip3 install -r ${base}/config/requirements.txt --user

# now add these to "${base}"/Docker/small_environment.yml
req=$(grep -v pip < ${base}/config/requirements.txt)
cp "${base}"/config/small_environment.yml "${base}"/Docker/small_environment.yml 
for n in ${req[@]}
do
  grep -v $n < "${base}"/Docker/small_environment.yml > /tmp/tmp2.$$
  mv /tmp/tmp2.$$ "${base}"/Docker/small_environment.yml
done
awk < ${base}/config/requirements.txt '{print "    - "$0}' >> "${base}"/Docker/small_environment.yml

# test it
#conda env create -n small  --force -f "${base}"/Docker/small_environment.yml



#rm -rf "$base/docs/sphinx"
#mkdir -p "$base/docs/sphinx"
cd "$base"
#sphinx-quickstart -q -p "GEOG0111 Scientific Computing" -a "P. Lewis and J. Gomez-Dans" -v "1.0.1" -l "en" --ext-autodoc --ext-doctest --ext-viewcode --ext-githubpages --ext-intersphinx docs/sphinx
#cp "$base/config/conf.py" docs/sphinx


echo "--> re-making notebooks_lab"
rm -rf site
rm -rf */*nbconvert*
rm -rf notebooks_lab/*_files notebooks_lab/*ipynb notebooks_lab/*md
# filter notebooks from notebooks into notebooks_lab
geog0111/edit_notebook.py

bin/link-set.sh


echo "--> creating markdown files in notebooks_lab"
# make markdown from the ipynb in notebooks_lab/???_*ipynb
jupyter nbconvert --ExecutePreprocessor.timeout=600 --ExecutePreprocessor.allow_errors=True \
    --nbformat=4 --ExecutePreprocessor.store_widget_state=True --to markdown notebooks_lab/???_*ipynb

echo "--> staging markdown files into docs"
# mv into docs
mv notebooks_lab/*_files docs
mv notebooks_lab/*md docs
rm -f docs/README.md

for i in docs/*md
do
  sed < $i > /tmp/$$ 's/.ipynb/.md/g'
  mv /tmp/$$ $i
done

# generate docs/index.md 

echo "--> adding to docs/index.md"

cat << EOF >> docs/index.md 

Last update: {{ git_revision_date_localized }}

EOF

# get files
cd "$base"
files=docs/*_files
filedirs=$(echo $files | sed 's/docs\///g')
#cd "$base"/docs/sphinx
#for n in ${filedirs[@]}
#do
#  ln -s ../$n $n
#done

cd "$base"
echo "--> generating mkdocs files for docs"
geog0111/mkdocs_prep.py --dev
echo "--> building mkdocs"

#echo "--> generating sphinx files for docs"
#cp  config/index_head.rst docs/index.rst
#awk < mkdocs.yml -F: 'BEGIN{start=0} ($1=="nav"){start=1} ($1=="plugins"){start=0} (start==1 && $1!="nav"){print "  "$NF}' >> docs/index.rst
#cat config/index_tail.rst >> docs/index.rst

cd $base/notebooks
for i in *md ; do
  sed < $i 's/ipynb/md/g' > $base/docs/$i
done

cd $base
mkdocs build -v
cd $base/docs
cp ../config/requirements.txt .
#cd $base/docs/sphinx
#ln -s ../bin bin
#ln -s ../images images
#ln -s ../data data
#ln -s ../work work
#ln -s ../geog0111 geog0111
#ln -s ../copy copy
#sed < $base/docs/index.rst 's/index.md/docindex.md/' > tmp.$$
#mv tmp.$$ index.rst
#rm -f index.md
#cp ../*.md ../*.html .

# dont confuse index.md with index.rst
#if [ -f "index.md" ]; then
#  mv index.md docindex.md
#else
#  cp ../index.md docindex.md
#fi

#cp ../index.rst .
#make clean html
cd $base
echo "----> done running $0 from $base"
echo "to upload, run:  mkdocs gh-deploy --force"
