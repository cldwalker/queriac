# CocoaMySQL dump
# Version 0.7b5
# http://cocoamysql.sourceforge.net
#
# Host: localhost (MySQL 5.0.37)
# Database: monoquery_development
# Generation Time: 2007-09-02 20:21:57 +0200
# ************************************************************

# Dump of table commands
# ------------------------------------------------------------

CREATE TABLE `commands` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `keyword` varchar(255) default NULL,
  `url` text,
  `description` text,
  `kind` varchar(255) default NULL,
  `origin` varchar(255) default 'hand',
  `created_at` datetime default NULL,
  `modified_at` datetime default NULL,
  `bookmarklet` tinyint(1) default '0',
  `user_id` int(11) default NULL,
  `public` tinyint(1) default '1',
  `public_queries` tinyint(1) default '1',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('1','Google Quicksearch','g','http://www.google.com/search?complete=1&q=---1---','','parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('2','Google Image Quicksearch','i','http://images.google.com/images?q=---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('5','Google French to English Quicksearch','ftoe','http://translate.google.com/translate_t?langpair=fr|en&text=---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('7','Google German to English Quicksearch','gtoe','http://translate.google.com/translate_t?langpair=de|en&text=---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('8','Google English to German Quicksearch','etog','http://translate.google.com/translate_t?langpair=en|de&text=---1---','','parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('10','Google English to Italian Quicksearch','etoi','http://translate.google.com/translate_t?langpair=en|it&text=---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('11','Google Maps','maps','http://maps.google.com/maps',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('12','Google Wikipedia Quicksearch','wiki','http://www.google.com/search?complete=1&q=site:en.wikipedia.org%20---1---','asdfasdfASDFASDFASDFA','parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('13','Google Wiktionary Quicksearch','wiktionary ','http://www.google.com/search?complete=1&q=site:en.wiktionary.org%20---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('14','Google News Quicksearch','news','http://news.google.com/news?q=---1---&hl=en&ned=us',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('15','Google Music Quicksearch','gm','http://www.google.com/search?complete=1&q=-inurl:htm%20-inurl:html%20intitle:%22index%20of%22%20mp3%20%22---1---%22','','parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('17','Google Music Quicksearch','m','http://www.google.com/musicsearch?q=---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('18','Google AllMusic Quicksearch','am','http://www.google.com/search?complete=1&q=site:allmusic.com%20---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('19','OED Quicksearch','oed','http://dictionary.oed.com/cgi/findword?query_type=word&queryword=---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('20','Dictionary.com Quicksearch','word','http://dictionary.reference.com/browse/---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('21','Thesaurus.com Quicksearch','words','http://thesaurus.reference.com/browse/---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('22','Urban Dictionary Quicksearch','slang','http://www.urbandictionary.com/define.php?term=---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('23','Bartleby Search','bart','http://www.bartleby.com/cgi-bin/texis/webinator/sitesearch?query=---1---&FILTER=&=Select%20reference&=Select%20verse&=Select%20fiction&=Select%20nonfiction',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('24','Rhyming Dictionary','rhyme','http://www.rhymezone.com/r/rhyme.cgi?Word=---1---&typeofrhyme=perfect&org1=syl&org2=l',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('25','dict.org Word Definition Lookup','dict','http://www.dict.org/bin/Dict?Form=Dict2&Database=*&Query=---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('28','Jobs Quicksearch','j','http://internal.rgcreative.com/jobs.php?searchTerm=---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('29','Jobs Details Quicksearch','jd','http://internal.rgcreative.com/jobs_edit.php?action=editJob&job_id=---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('30','Directory Quicksearch','d','http://internal.rgcreative.com/directory.php?searchTerm=---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('31','Acronym Quicksearch','acr','http://www.acronymfinder.com/af-query.asp?p=dict&String=exact&Acronym=---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('32','Archive.org Quicksearch','archive','http://www.archive.org/searchresults.php',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('33','Astakiller Crack Search','crack','http://astakiller.com/?srch=---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('34','Bernalillo County Court Records Quicksearch','court','http://164.64.140.2/casemanagement/csprocess.jsp',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('35','Brands of the World QuickSearch','logo','http://www.brandsoftheworld.com/search/?text=---1---&action=1',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('36','DaFont Quicksearch','df','http://dafont.com/en/search.php?q=---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('38','Netflix Quicksearch','nf','http://www.netflix.com/Search?v1=---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('39','TorrentSpy Quicksearch','tspy','http://www.torrentspy.com/search.asp?query=---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('40','WayBack Machine QuickSearch','old','http://web.archive.org/---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('41','Whois Lookup','whois','http://www.whois.sc/---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('42','Wikipedia Quickjump','wj','http://en.wikipedia.org/wiki/---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('43','Del.icio.us Quicksearch - All','lish','http://del.icio.us/search/?all=---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('44','Del.icio.us Quicksearch - Mine','mish','http://del.icio.us/sikelianos/---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('45','Stock.Xchng','sxc','http://www.sxc.hu/browse.phtml?txt=---1---&f=search&w=1',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('46','Technorati Quicksearch','t','http://technorati.com/search.php',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('47','Flickr Quicksearch','fs','http://www.flickr.com/photos/tags/---1---/','','parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('48','VersionTracker Quicksearch','vt','http://www.versiontracker.com/php/search.php?str=---1---&mode=basic&action=search&plt%5B%5D=macosx',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('49','zeke.sikelianos.com/blog Quicksearch','b','http://zeke.sikelianos.com/blog/index.php?search_term=---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('50','RetailMeNot.com','promo','http://www.retailmenot.com/view/---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('51','Unix MAN Pages','man','http://unixhelp.ed.ac.uk/CGI/man-cgi?---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('53','Google &quot;I\'m Feeling Lucky&quot; Result: Wikipedia','w','http://www.google.com/search?btnI=I\'m%20Feeling%20Lucky&q=site:en.wikipedia.org%20---1---',NULL,'parametric','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('54','RGC Internal','int','http://internal.rgcreative.com',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('55','Directory','dir','http://internal.rgcreative.com/directory.php',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('56','Hours','hours','http://internal.rgcreative.com/hours.php',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('57','Jobs','jobs','http://internal.rgcreative.com/jobs.php',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('58','http://internal.rgcreative.com/job_files/list.php','jf','http://internal.rgcreative.com/job_files/list.php',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('59','RGC phpMyAdmin','rgcpma','http://internal.rgcreative.com/pma/',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('60','Plesk Server Admin','plesk','https://67.19.146.186:8443/',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('61','Orbit Customer Portal','orbit','https://orbit.theplanet.com/',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('63','Ideum Appliance','a','https://65.18.178.249:19638/webhost/',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('64','Ideum phpMyAdmin','pma','http://65.18.178.249/MyAdmin/index.php',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('65','IGLO','iglo','http://www.astc.org/iglo/',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('66','IGLO phpMyAdmin','iglopma','http://69.94.73.60/MyAdmin/index.php',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('67','IGLO Appliance','igloa','https://69.94.73.60:19638/webhost/',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('68','MuseumBlogs.org','mb','http://museumblogs.org/',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('70','MuseumBlogs.org - Wordpress','mbb','http://museumblogs.org/wp-admin/',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('71','RecycleMap: Torrance','tor','http://ideum.com/work-torrance/',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('72','Financial Analysis Tool &gt; Overview','gocamp','http://godev.grouphub.com/projects/848895/project/log',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('74','Green Options PMA','gopma','http://www.greenoptions.com/pma/',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('75','Green Options: Financial Analysis Tool (Local)','lfat','http://localhost:8888/greenoptions.com/FAT/Publish/index.php',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('76','Green Options: Financial Analysis Tool','fat','http://www.greenoptions.com/fat/',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('77','MAMP','mamp','http://localhost:8888/MAMP/',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('78','Localhost','ml','http://localhost:3000/',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('79','Localhost phpMyAdmin','lpma','http://localhost:8888/phpMyAdmin/',NULL,'shortcut','import','2007-07-12 20:07:13',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('81','Grid PMA','gpma','http://s1939.gridserver.com/phpMyAdmin/',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('82','Media Temple : AccountCenter','mt','https://ac.mediatemple.net/services/manage/index.mt?domain=sikelianos.com&server=137443',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('83','Del.icio.us - Post Current Page','ish','javascript:location.href=\'http://del.icio.us/sikelianos?v=3&url=\'+encodeURIComponent(location.href)+\'&title=\'+encodeURIComponent(document.title)+\'&tags=---1---\'+\'&notes=\'+window.getSelection()',NULL,'parametric','import','2007-07-12 20:07:14',NULL,'1','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('84','Lorem Ipsum','lipsum','http://zeke.sikelianos.com/words/lipsum.html',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('86','http://zeke.sikelianos.com/dump/','dump','http://zeke.sikelianos.com/dump/',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('87','FCBNM ezBanking','bank','https://enterprise2.openbank.com/fi1291/logon/user',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('88','Unix Timestamp Converter','timestamp','http://www.4webhelp.net/us/timestamp.php',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('89','My Ta-da Lists','tada','http://sikelianos.tadalist.com/lists/all','My TaDa list','shortcut','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('90','Send a Text Message (SMS)','sms','http://toolbar.google.com/send/sms/index.php',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('91','IP Address','ip','http://internal.rgcreative.com/ip.php',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('92','Google Calendar','cal','http://www.google.com/calendar/render',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('93','Flickr: Photos from sikelianos','f','http://flickr.com/photos/sikelianos/','','shortcut','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('94','Blog','blog','http://zeke.sikelianos.com/blog',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('95','Love Blog: &quot;Blog of Loves&quot;','love','http://zeke.sikelianos.com/love/index.php',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('96','Gmail - Inbox','mail','http://mail.google.com/mail/?auth=DQAAAHcAAADUSLXzTskFgstIP3alBXKvXaFBAPSJ5MxR_qajbEjx6lDzSkPmencqiO1y_3gUkYtXz6SCsOvRhPwtzHHi6iBcLb3fyr_Qr0iO2cYnWfOx2ed46SGQu4nrBU1Gi7DTSJAySKI07gTp1zD9SAZl5F9otq7J-yeTLu3yYKKT7cLtmA',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('97','Rails Localhost','rl','http://localhost:3000',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('98','Subscribe with Google Reader','subscribe','javascript:var%20b=document.body;if(b){void(z=document.createElement(\'script\'));void(z.src=\'http://www.google.com/reader/ui/subscribe-bookmarklet.js\');void(b.appendChild(z));}else{location=\'http://www.google.com/reader/view/feed/\'+encodeURIComponent(locat',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'1','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('99','Page Last Modified','age','javascript:if(frames.length>1)alert(\'Sorry, frames detected.\');else{var lm=new Date(document.lastModified);var now=new Date();if(lm.getTime()==0||now.toUTCString()==lm.toUTCString()){alert(\'Page is dynamically generated, cannot determine date.\');}else{ale',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'1','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('100','User Agent Info','agent','javascript:document.write(navigator.userAgent)',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'1','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('101','View Cookies','cookies','javascript:alert(\'Cookies%20stored%20by%20this%20host%20or%20domain:%5Cn%5Cn\'%20+%20document.cookie.replace(/;%20/g,\'%5Cn\'));',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'1','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('102','View Passwords','passwords','javascript:(function(){var s,F,j,f,i; s = %22%22; F = document.forms; for(j=0; j<F.length; ++j) { f = F[j]; for (i=0; i<f.length; ++i) { if (f[i].type.toLowerCase() == %22password%22) s += f[i].value + %22\\n%22; } } if (s) alert(%22Passwords in forms on t',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'1','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('103','Word Counter','count','javascript:(function()%7Bvar%20T=%7B%7D,W=%5B%5D,C=0,s,i;%20function%20F(n)%7Bvar%20i,x,a,w,t=n.tagName;if(n.nodeType==3)%7Ba=n.data.toLowerCase().split(/%5B%5Cs%5C(%5C)%5C:%5C,%5C.;%5C%3C%5C%3E%5C&%5C\'%5C%22%5D/),i;for(i%20in%20a)if(w=a%5Bi%',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'1','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('104','Show Hidden Forms Fields','hidden','javascript:(function(){var i,f,j,e,div,label,ne; for(i=0;f=document.forms[i];++i)for(j=0;e=f[j];++j)if(e.type==%22hidden%22){ D=document; function C(t){return D.createElement(t);} function A(a,b){a.appendChild(b);} div=C(%22div%22); label=C(%22label%22); ',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'1','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('105','CSSEdit: Preview','css','javascript:document.location.href=\'cssedit:preview?\'+location.href;',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'1','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('106','ELC Dashboard','dash','http://dashboard.elctech.com/',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('107','Rails Framework Documentation','api','http://api.rubyonrails.org/',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('108','ELC Signature','sig','http://zeke.sikelianos.com/elc/signature.txt',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('109','ELC Wush SVN Quickjump','svn','https://wush.net/svn/---1---/',NULL,'parametric','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('110','Trac Quicksearch','trac','https://wush.net/trac/---1---/',NULL,'parametric','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('111','WordReference.com - English to French','enfr','http://wordreference.com/enfr/---1---',NULL,'parametric','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('112','WordReference.com - English to French','fren','http://wordreference.com/fren/---1---',NULL,'parametric','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('113','Flickr: Sikelianos: Tag Search','flickr','http://flickr.com/search/?w=22863082%40N00&m=tags&q=---1---','','parametric','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('114','Sikelianos\' Photosets on Flickr','sets','http://flickr.com/photos/sikelianos/sets/',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('115','Verb Conjugation','verb2','http://humanities.uchicago.edu/orgs/ARTFL/forms_unrest/inflect.query.html',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('116','français interactif – verb conjugation reference','verb','http://www.laits.utexas.edu/fi/vcr/',NULL,'shortcut','import','2007-07-12 20:07:14',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('117','Simple Javascript Alert','alert','javascript:alert(\'hello\');',NULL,'shortcut','hand','2007-07-13 11:30:35',NULL,'1','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('118','Subscribe in Google Reader (Redux)','sub','javascript:(function (){var l=\"/reader/view/\";;;function k(){var f=false,m=document.getElementsByTagName(\"link\");function n(e){var j=e,c=window.document.location;if(e.indexOf(\"/\")!=0){var d=c.pathname.split(\"/\");d[d.length-1]=e;j=d.join(\"/\")}return c.protocol+\"//\"+c.hostname+j}for(var g=0,a;a=m[g];g++){var h=a.getAttribute(\"type\"),i=a.getAttribute(\"rel\");if(h&&h.match(/[\\+\\/]xml$/)&&i&&i==\"alternate\"){var b=a.getAttribute(\"href\");if(b.indexOf(\"http\")!=0){b=n(b)}window.document.location=\"http://www.google.com\"+l+\"feed/\"+encodeURIComponent(b);f=true;break}}if(!f)alert(\"Oops. Can\'t find a feed.\")}k();})();','','shortcut','hand','2007-07-16 12:05:08',NULL,'1','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('121','Metro Map','metro','http://flickr.com/photo_zoom.gne?id=827269165&size=o',NULL,'shortcut','hand','2007-08-07 14:00:56',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('122','Test','test','http://',NULL,'shortcut','hand','2007-08-08 23:59:21',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('123','Test','cov','file://localhost/Users/zeke/Projects/blogitive/trunk/coverage/index.html','','shortcut','hand','2007-08-09 00:00:01',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('124','Test','wowsah','http://test.com','wowsah','shortcut','hand','2007-08-09 00:25:56',NULL,'0','1','1','1');
INSERT INTO `commands` (`id`,`name`,`keyword`,`url`,`description`,`kind`,`origin`,`created_at`,`modified_at`,`bookmarklet`,`user_id`,`public`,`public_queries`) VALUES ('125','this','this','http://this.com','this','shortcut','hand','2007-08-09 00:35:17',NULL,'0','1','1','1');


# Dump of table queries
# ------------------------------------------------------------

CREATE TABLE `queries` (
  `id` int(11) NOT NULL auto_increment,
  `command_id` varchar(255) default NULL,
  `query_string` varchar(255) default NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('1','1','dog','2007-07-13 10:14:41');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('2','1','cat','2007-07-13 10:27:12');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('3','1','the legacy of thelonious monk','2007-07-13 10:29:17');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('5','103','','2007-07-13 11:28:00');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('6','103','','2007-07-13 11:29:23');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('7','117','','2007-07-13 11:30:42');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('8','1','dog','2007-07-15 18:23:57');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('9','31','fbi','2007-07-15 18:24:06');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('10','83','wtf','2007-07-15 18:33:19');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('11','83','wtf','2007-07-15 19:18:02');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('12','83','wtf','2007-07-15 19:18:11');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('13','83','wtf','2007-07-15 19:18:54');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('14','83','wtf','2007-07-15 19:19:15');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('15','83','fuck','2007-07-15 19:20:24');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('16','83','wtf','2007-07-15 19:20:35');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('17','31','nsa','2007-07-15 21:09:19');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('18','44','mt rails','2007-07-19 11:51:41');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('19','44','mt rails','2007-07-19 11:51:44');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('20','44','mt rails','2007-07-19 11:51:53');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('21','44','mt rails','2007-07-19 11:52:37');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('22','44','mt rails','2007-07-19 11:53:05');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('23','44','mt rails','2007-07-19 11:53:25');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('24','44','mt rails','2007-07-19 11:53:29');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('25','1','dog meat','2007-07-19 11:53:43');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('26','1','dog','2007-07-19 11:55:11');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('27','1','dog','2007-07-19 11:55:35');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('28','1','dog','2007-07-24 19:55:20');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('29','44','regex','2007-07-24 20:13:35');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('30','1','','2007-07-24 21:38:04');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('31','1','','2007-07-24 22:03:39');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('32','1','validates_uniqueness_of scope','2007-07-24 22:22:30');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('33','1','','2007-07-25 11:19:39');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('34','1','dog','2007-07-25 11:23:19');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('35','1','','2007-07-25 11:24:25');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('36','1','','2007-07-25 11:25:14');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('37','1','','2007-07-25 11:32:07');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('38','82','','2007-07-25 14:54:07');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('39','83','','2007-07-25 14:56:43');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('40','83','adium','2007-07-25 15:28:39');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('41','83','adium themes','2007-07-25 15:29:15');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('42','89','','2007-07-26 20:03:09');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('43','1','','2007-08-07 14:33:49');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('44','1','','2007-08-07 14:34:11');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('45','1','','2007-08-07 14:34:48');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('46','1','','2007-08-07 14:35:02');
INSERT INTO `queries` (`id`,`command_id`,`query_string`,`created_at`) VALUES ('47','123','','2007-08-09 00:00:10');


# Dump of table schema_info
# ------------------------------------------------------------

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

INSERT INTO `schema_info` (`version`) VALUES ('10');


# Dump of table taggings
# ------------------------------------------------------------

CREATE TABLE `taggings` (
  `id` int(11) NOT NULL auto_increment,
  `tag_id` int(11) NOT NULL,
  `taggable_id` int(11) NOT NULL,
  `taggable_type` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_taggings_on_tag_id_and_taggable_id_and_taggable_type` (`tag_id`,`taggable_id`,`taggable_type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `taggings` (`id`,`tag_id`,`taggable_id`,`taggable_type`) VALUES ('1','1','1','Command');
INSERT INTO `taggings` (`id`,`tag_id`,`taggable_id`,`taggable_type`) VALUES ('5','1','12','Command');
INSERT INTO `taggings` (`id`,`tag_id`,`taggable_id`,`taggable_type`) VALUES ('2','2','12','Command');
INSERT INTO `taggings` (`id`,`tag_id`,`taggable_id`,`taggable_type`) VALUES ('3','3','12','Command');
INSERT INTO `taggings` (`id`,`tag_id`,`taggable_id`,`taggable_type`) VALUES ('6','4','1','Command');
INSERT INTO `taggings` (`id`,`tag_id`,`taggable_id`,`taggable_type`) VALUES ('7','5','1','Command');
INSERT INTO `taggings` (`id`,`tag_id`,`taggable_id`,`taggable_type`) VALUES ('11','5','125','Command');
INSERT INTO `taggings` (`id`,`tag_id`,`taggable_id`,`taggable_type`) VALUES ('8','6','89','Command');
INSERT INTO `taggings` (`id`,`tag_id`,`taggable_id`,`taggable_type`) VALUES ('9','7','89','Command');
INSERT INTO `taggings` (`id`,`tag_id`,`taggable_id`,`taggable_type`) VALUES ('10','8','89','Command');
INSERT INTO `taggings` (`id`,`tag_id`,`taggable_id`,`taggable_type`) VALUES ('12','9','125','Command');
INSERT INTO `taggings` (`id`,`tag_id`,`taggable_id`,`taggable_type`) VALUES ('13','10','1','Command');
INSERT INTO `taggings` (`id`,`tag_id`,`taggable_id`,`taggable_type`) VALUES ('14','11','1','Command');
INSERT INTO `taggings` (`id`,`tag_id`,`taggable_id`,`taggable_type`) VALUES ('15','12','1','Command');
INSERT INTO `taggings` (`id`,`tag_id`,`taggable_id`,`taggable_type`) VALUES ('16','13','1','Command');
INSERT INTO `taggings` (`id`,`tag_id`,`taggable_id`,`taggable_type`) VALUES ('25','14','47','Command');
INSERT INTO `taggings` (`id`,`tag_id`,`taggable_id`,`taggable_type`) VALUES ('18','14','93','Command');
INSERT INTO `taggings` (`id`,`tag_id`,`taggable_id`,`taggable_type`) VALUES ('20','14','113','Command');


# Dump of table tags
# ------------------------------------------------------------

CREATE TABLE `tags` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_tags_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `tags` (`id`,`name`) VALUES ('6','37signals');
INSERT INTO `tags` (`id`,`name`) VALUES ('11','boy');
INSERT INTO `tags` (`id`,`name`) VALUES ('10','cat');
INSERT INTO `tags` (`id`,`name`) VALUES ('4','dog');
INSERT INTO `tags` (`id`,`name`) VALUES ('9','etc');
INSERT INTO `tags` (`id`,`name`) VALUES ('14','flickr');
INSERT INTO `tags` (`id`,`name`) VALUES ('1','google');
INSERT INTO `tags` (`id`,`name`) VALUES ('8','tada');
INSERT INTO `tags` (`id`,`name`) VALUES ('5','test');
INSERT INTO `tags` (`id`,`name`) VALUES ('7','todo');
INSERT INTO `tags` (`id`,`name`) VALUES ('3','wiki');
INSERT INTO `tags` (`id`,`name`) VALUES ('2','wikipedia');
INSERT INTO `tags` (`id`,`name`) VALUES ('12','wtf');
INSERT INTO `tags` (`id`,`name`) VALUES ('13','wtf2');


# Dump of table users
# ------------------------------------------------------------

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `login` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `crypted_password` varchar(40) default NULL,
  `salt` varchar(40) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `remember_token` varchar(255) default NULL,
  `remember_token_expires_at` datetime default NULL,
  `activation_code` varchar(40) default NULL,
  `activated_at` datetime default NULL,
  `default_command` int(11) default NULL,
  `first_name` varchar(255) default NULL,
  `last_name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `users` (`id`,`login`,`email`,`crypted_password`,`salt`,`created_at`,`updated_at`,`remember_token`,`remember_token_expires_at`,`activation_code`,`activated_at`,`default_command`,`first_name`,`last_name`) VALUES ('1','zeke','zeke@sikelianos.com','bb7d4d642766be826d7d16918ada3b124426b78d','3cf8b9027e4e530d903f272ab67dde54440a9ac1','2007-07-23 11:36:20','2007-07-25 10:27:53',NULL,NULL,NULL,'2007-07-23 09:47:52',NULL,NULL,NULL);
INSERT INTO `users` (`id`,`login`,`email`,`crypted_password`,`salt`,`created_at`,`updated_at`,`remember_token`,`remember_token_expires_at`,`activation_code`,`activated_at`,`default_command`,`first_name`,`last_name`) VALUES ('8','test','test@test.com','262fdd9db0b85b1632198e1d3542483e43b5a346','3a9dcfb2ec2fcb69a0c646697ae3a32c6827e027','2007-09-02 17:42:36','2007-09-02 17:43:41',NULL,NULL,NULL,'2007-09-02 15:42:55',NULL,'Zeke','Sikelianos');


