-- Clean Database Schema for Railway Cloud Deployment

CREATE TABLE IF NOT EXISTS `do_files` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `doid` varchar(45) NOT NULL,
  `doname` varchar(45) NOT NULL,
  `enc_data` longblob NOT NULL,
  `dkey` longtext NOT NULL,
  `time` varchar(45) NOT NULL,
  `filekeyword` varchar(450) NOT NULL,
  `filename` longtext NOT NULL,
  `data` longblob NOT NULL,
  `block1` longblob NOT NULL,
  `block2` longblob NOT NULL,
  `block3` longblob NOT NULL,
  `hash1` varchar(255) NOT NULL,
  `hash2` varchar(255) NOT NULL,
  `hash3` varchar(255) NOT NULL,
  `ori_block1` longblob NOT NULL,
  `ori_block2` longblob NOT NULL,
  `ori_block3` longblob NOT NULL,
  `rdkey` longblob NOT NULL,
  `reencrypt_data` longblob NOT NULL,
  `encryptTime` varchar(455) NOT NULL,
  `tx_hash` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `do_reg` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `email` varchar(45) NOT NULL,
  `dob` varchar(45) NOT NULL,
  `gender` varchar(45) NOT NULL,
  `phone` varchar(45) NOT NULL,
  `address` varchar(400) NOT NULL,
  `password` varchar(255) NOT NULL,
  `status` varchar(45) NOT NULL DEFAULT 'waiting',
  `private_key` varchar(455) NOT NULL,
  `reg_date` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `du_reg` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `email` varchar(45) NOT NULL,
  `dob` varchar(45) NOT NULL,
  `gender` varchar(45) NOT NULL,
  `phone` varchar(45) NOT NULL,
  `address` varchar(400) NOT NULL,
  `password` varchar(255) NOT NULL,
  `status` varchar(45) NOT NULL DEFAULT 'waiting',
  `private_key` varchar(455) NOT NULL,
  `reg_date` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `download` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` varchar(45) NOT NULL,
  `uname` varchar(45) NOT NULL,
  `filename` varchar(45) NOT NULL,
  `time` datetime NOT NULL,
  `fileid` varchar(45) NOT NULL,
  `doname` varchar(45) NOT NULL,
  `doid` varchar(45) NOT NULL,
  `decrypt_time` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `request` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` varchar(45) NOT NULL,
  `uname` varchar(255) NOT NULL,
  `umail` varchar(255) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `filekeyword` varchar(255) DEFAULT NULL,
  `time` varchar(45) NOT NULL,
  `fid` varchar(45) NOT NULL,
  `doid` varchar(45) NOT NULL,
  `doname` varchar(255) DEFAULT NULL,
  `dkey` varchar(455) DEFAULT NULL,
  `status` varchar(45) NOT NULL DEFAULT 'waiting',
  `dostatus` varchar(45) NOT NULL DEFAULT 'waiting',
  `rdkey` varchar(450) NOT NULL DEFAULT 'waiting',
  `tx_hash` varchar(100) DEFAULT NULL,
  `granted_time` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `login_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_type` varchar(45) NOT NULL,
  `user_id` varchar(45) NOT NULL,
  `email` varchar(255) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `status` varchar(45) NOT NULL,
  `login_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

-- Seed Default Test Accounts (Passwords hashed with SHA-256 for '1234')
INSERT INTO `do_reg` (`id`, `name`, `email`, `dob`, `gender`, `phone`, `address`, `password`, `status`, `private_key`, `reg_date`) VALUES
(1, 'abdul', 'abdulhathi.jpinfotech@gmail.com', '1999-03-22', 'Male', '0557185634', 'Pondicherry', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'Approved', '+DjLGVNxIYA=', '2026-08-23 12:46:20'),
(2, 'sikapa', 'princentiamoah3476@gmail.com', '2001-02-09', 'Male', '0557185634', 'dwomo', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'Approved', 'VAC4uFdeRe8=', '2026-08-23 12:46:20');

INSERT INTO `du_reg` (`id`, `name`, `email`, `dob`, `gender`, `phone`, `address`, `password`, `status`, `private_key`, `reg_date`) VALUES
(1, 'abdul', 'abdulhathi.jpinfotech@gmail.com', '1999-03-22', 'Male', '0557185634', 'Pondicherry', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'Approved', '+DjLGVNxIYA=', '2026-08-23 12:46:20'),
(2, 'sikapa', 'princentiamoah3476@gmail.com', '2001-02-09', 'Male', '0557185634', 'dwomo', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'Approved', 'VAC4uFdeRe8=', '2026-08-23 12:46:20'),
(3, 'samuel', 'stutu4288@gmail.com', '2000-01-01', 'Male', '0557185634', 'Accra', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'Approved', '9w6UixB4rIA=', '2026-08-23 12:46:20');