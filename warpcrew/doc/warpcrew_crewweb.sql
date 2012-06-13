-- Eksempel database-dump

--
-- Table structure for table `crew`
--

DROP TABLE IF EXISTS `crew`;
CREATE TABLE `crew` (
  `crew_id` int(11) NOT NULL auto_increment,
  `crew_navn` varchar(250) NOT NULL default '',
  PRIMARY KEY  (`crew_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

