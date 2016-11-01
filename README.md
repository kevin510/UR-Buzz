<h1>UR BUZZ</h1>
<br>
<p>
	This is a web application developed for CSC210 at the University of Rochester. This site itself has no affiliation with the University of Rochester. Much of the application foundation was developed with the guidance and help of the <a href="https://www.railstutorial.org/"><em>Ruby on Rails Tutorial: Learn Web Development with Rails</em></a> by <a href="http://www.michaelhartl.com/">Michael Hartl</a>.
</p>
<h3>Application Setup</h3>
<code>
	# Move to the desired workspace directory
	$ cd ~/workspace

	# Clone the GitHub project
	$ git clone https://github.com/sbudker/ur_buzz.git

	# Install the application gems
	$ bundle install --without production

	# Make any necessary database migrations
	$ rails db:migrate

	# Run the rails server localy
	$ rails s
</code>
