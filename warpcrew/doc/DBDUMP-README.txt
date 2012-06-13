Must have a running dev server (vagrant up)

- Go to http://localhost:10080/phpmyadmin/
- Login as root, no password
- Go to the database you want to dump
- Go to the Export tab
- Select either "Structure" or "Data" and select the settings below.
- Save to file or paste the dump into the right file depending on what database it is and if it is structure or data


Structure:
- Check "Add DROP TABLE / VIEW / PROCEDURE / FUNCTION / EVENT"
- Uncheck "Add AUTO_INCREMENT value"
- Other values on default

Data:
- default settings
