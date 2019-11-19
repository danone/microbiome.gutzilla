import qiime2
import click
import pandas as pd
import biom


def _single_subject(md):
    md = md.copy()
    md['collection_date_only'] = pd.to_datetime(md['collection_date_only'],
                                                errors='coerce')
    md.sort_values('collection_date_only', inplace=True)
    md['single_subject_sample'] = ~md['host_subject_id'].duplicated()
    return md


def _id_overlap(tab, md):
    assert set(tab.ids()).issubset(set(md.index))
    return md.loc[list(tab.ids())]


def _categories_and_types(categories):
    if not categories:
        return [], []

    cats = []
    types = []

    for cat in categories:
        if '::' in cat:
            label, type = cat.split('::', 1)
            assert type in ('categorical', 'numeric')
            cats.append(label)
            types.append(type)
    return cats, types


@click.group()
@click.pass_context
def cli(ctx):
    pass


@cli.command()
@click.option('--table', type=click.Path(exists=True), required=True)
@click.option('--metadata', type=click.Path(exists=True), required=True)
@click.option('--output', type=click.Path(exists=False), required=True)
def single_subject(table, metadata, output):
    """Pick a single sample per subject

    The sample picked must exist in the input feature table. And, the sample
    picked is based off the collection date such that the "oldest" sample
    is chosen.
    """
    tab = qiime2.Artifact.load(table).view(biom.Table)
    md = pd.read_csv(metadata, sep='\t', dtype=str).set_index('#SampleID')

    md = _id_overlap(tab, md)
    md = _single_subject(md)

    md.to_csv(output, sep='\t', index=True, header=True)


@cli.command()
@click.option('--table', type=click.Path(exists=True), required=True)
@click.option('--metadata', type=click.Path(exists=True), required=True)
@click.option('--output', type=click.Path(exists=False), required=True)
@click.option('--additional-category', type=str, required=False,
              multiple=True)
def extract_latlong(table, metadata, output, additional_categories):
    """Extract the latitude and longitude variables

    q2-coordinates can operate on these variables but they need to be both
    complete and described as numeric by QIIME2. The metadata from redbiom
    do not satisfy these constraints.

    Metadata are limited to single samples per subject as to not overrepresent
    positions in subsequent graphics.

    Additional category to retain can be specified with
    --additional-category, and can be provided multiple times. The column
    type will be assumed to be categorical unless "::numeric" is used. E.g.,
    "--additional-category age_years::numeric"
    """
    tab = qiime2.Artifact.load(table).view(biom.Table)
    md = pd.read_csv(metadata, sep='\t', dtype=str).set_index('#SampleID')

    md = _id_overlap(tab, md)
    md = _single_subject(md)

    categories, category_types = _categories_and_types(additional_categories)
    categories.extend(['latitude', 'longitude'])
    category_types.extend(['numeric', 'numeric'])

    assert set(categories).issubset(set(md.columns))

    latlong = md[categories]
    for cat, type in zip(categories, category_types):
        if type == 'numeric':
            latlong[cat] = pd.to_numeric(latlong[cat], errors='coerce')
        elif type == 'categorical':
            pass
        else:
            raise ValueError('Unknown type: %s' % type)

    q2md = qiime2.Metadata(latlong)
    q2md.save(output)


if __name__ == '__main__':
    cli()
