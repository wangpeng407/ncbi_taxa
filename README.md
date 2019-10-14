### Description

- perl script for processing names.dmp and nodes.dmp 

  Download names.dmp and nodes.dmp from [here](ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdmp.zip)


### Example
```
perl ncbi_nodes_names_to_taxanomy.pl nodes.dmp names.dmp > taxa_info.list

```

#### NOTE

See result as taxa_info.list


- First column is taxa id 
  ```
  6
  ```
  
- Second is processed taxa information
  ```
  k__Bacteria;p__Proteobacteria;c__Alphaproteobacteria;o__Rhizobiales;f__Xanthobacteraceae;g__Azorhizobium
  ```

- Third is full taxa information (taxa level; taxa id; taxanomy)

  ```
  no rank__1(root);no rank__131567(cellular organisms);superkingdom__2(Bacteria);phylum__1224(Proteobacteria);class__28211(Alphaproteobacteria);order__356(Rhizobiales);family__335928(Xanthobacteraceae);genus__6(Azorhizobium)
  ```
