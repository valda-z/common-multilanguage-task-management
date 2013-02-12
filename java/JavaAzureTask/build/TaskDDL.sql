CREATE TABLE `Task` (
  `Id` varchar(32) NOT NULL,
  `Name` varchar(128) DEFAULT NULL,
  `Category` varchar(128) DEFAULT NULL,
  `Date` datetime DEFAULT NULL,
  `Complete` bit(1) DEFAULT b'0',
  `Image` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`Id`)
)
