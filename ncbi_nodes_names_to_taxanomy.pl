#!/usr/bin/perl -w
use strict;

@ARGV == 2 || die "perl $0 nodes.dmp names.dmp > taxa_info.list\n";

my ($nodefiles, $namefiles) = @ARGV;

taxonomy_connection($nodefiles, $namefiles);

############################################
sub taxonomy_connection{

	my ($node_file, $name_file) = @_;

	my (%taxa_parent_taxa, %taxa_level, @taxaids);

	open IN, $node_file || die $!;

	while(<IN>){
		chomp;
		my ($taxa_id, $parent_taxa_id, $level) = (split /\t/)[0, 2, 4];

		$taxa_parent_taxa{$taxa_id} = $parent_taxa_id;

		$taxa_level{$taxa_id} = $level;

		push @taxaids, $taxa_id;
	}
	close IN;

	my %taxainfo = get_scientific_name($name_file);

	for(@taxaids){

		my $info = bottom_to_up_find($_, \%taxa_parent_taxa, \%taxa_level, \%taxainfo);

		my $scientific_info = extract_taxa_info($info);
		print $_, "\t", $scientific_info, "\t", $info, "\n";
	}

}


sub bottom_to_up_find{
	my ($id, $taxa2parent, $taxa2level, $taxainfo) = @_;

	my $name = $taxainfo->{$id} ? $taxainfo->{$id} : 'Unclassified';

	my $taxa_chain = $taxa2level->{$id} . '__' . $id . "($name)";

	if($id == 1){

		return $taxa_chain;

	}else{

		return bottom_to_up_find($taxa2parent->{$id}, $taxa2parent, $taxa2level, $taxainfo) . ';' . $taxa_chain;

	}
}


sub get_scientific_name{

	my ($names) = @_;

	my %taxaid_name;

	open IN, $names || die $!;

	while(<IN>){
		chomp;

		(/scientific name/) || next;

		my ($taxa_id, $taxainfo) = (split /\t/)[0, 2];
		$taxainfo =~ s/;//g; $taxainfo =~ s/__/_/g;
		$taxaid_name{$taxa_id} = $taxainfo;
	}
	close IN;

	return %taxaid_name;

}


sub extract_taxa_info{

	my ($fulltaxainfo)  = @_;

	my @target_level = qw/superkingdom phylum class order family genus species subspecies/;
	my @brief_level = qw/k p c o f g s subs/;
	#no rank__1(root);no rank__131567(cellular organisms);superkingdom__2(Bacteria);no rank__1783257(PVC group);phylum__67812(Candidatus Omnitrophica);no rank__1047005(unclassified Candidatus Omnitrophica);species__1974739(Candidatus Omnitrophica bacterium CG02_land_8_20_14_3_00__42_8)
	#no rank__1(root);no rank__131567(cellular organisms);superkingdom__2759(Eukaryota);kingdom__33090(Viridiplantae);phylum__35493(Streptophyta);subphylum__131221(Streptophytina);no rank__3193(Embryophyta);no rank__58023(Tracheophyta);no rank__78536(Euphyllophyta);no rank__58024(Spermatophyta);no rank__3398(Magnoliophyta);no rank__1437183(Mesangiospermae);no rank__71240(eudicotyledons);no rank__91827(Gunneridae);no rank__1437201(Pentapetalae);order__3524(Caryophyllales);family__1804623(Chenopodiaceae);subfamily__1316646(Salicornioideae);genus__46104(Salicornia);subgenus__2116532(Salicornia subg. Salicornia);species__447744(Salicornia aff. perennans Wucherer 3a;09)
	my @taxa_peices = split /;/, $fulltaxainfo;

	my (%level_taxa, @temp_s_info);

	for my $p (@taxa_peices){
		$p =~ /no rank/ && next;
		my @temp_line = split /__/, $p;
		unless($temp_line[1] =~ /\d+\((.*?)\)$/){
			print STDERR "$p contains special characters \n";
		}
		my $t = $1 if $temp_line[1] =~ /\d+\((.*?)\)$/;
		$level_taxa{$temp_line[0]} = $t;
	}

	for my $i (0..$#target_level){
		my $temp_taxa = $level_taxa{$target_level[$i]} ? "$brief_level[$i]" . "__" . $level_taxa{$target_level[$i]} : "$brief_level[$i]" . "__Unclassified";
		push @temp_s_info, $temp_taxa;
	}
	my @removed_unclassified_info;
	if($fulltaxainfo=~/subspecies/){
		@removed_unclassified_info = @temp_s_info;
	}elsif($fulltaxainfo=~/species/){
		@removed_unclassified_info = @temp_s_info[0..$#target_level-1];
	}elsif($fulltaxainfo=~/genus/){
		@removed_unclassified_info = @temp_s_info[0..$#target_level-2];
	}elsif($fulltaxainfo=~/family/){
		@removed_unclassified_info = @temp_s_info[0..$#target_level-3];
	}elsif($fulltaxainfo=~/order/){
		@removed_unclassified_info = @temp_s_info[0..$#target_level-4];
	}elsif($fulltaxainfo=~/class/){
		@removed_unclassified_info = @temp_s_info[0..$#target_level-5];
	}elsif($fulltaxainfo=~/phylum/){
		@removed_unclassified_info = @temp_s_info[0..$#target_level-6];
	}else{
		@removed_unclassified_info = @temp_s_info[0..$#target_level-7];
	}

	my $scientific_info = join(";", @removed_unclassified_info);

	return $scientific_info;

}
