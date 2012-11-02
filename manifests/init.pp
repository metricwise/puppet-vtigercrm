class vtigercrm {
	vtigercrm::webapp { $::hostname: 
		provider => "svn",
		version => "6.0.0"
	}
}
