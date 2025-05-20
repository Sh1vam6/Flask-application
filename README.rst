Flask Application CI/CD with Jenkins
======
This project demonstrates how to set up a CI/CD pipeline for a Flask application using Docker and Jenkins hosted on an EC2 instance.

Local Setup
-------

**Be sure to use the same version of the code as the version of the docs
you're reading.** You probably want the latest tagged version, but the
default Git version is the main branch. ::

    # clone the repository
    $ git clone https://github.com/Sh1vam6/Flask-application.git
    $ cd Flask-application
    

Create a virtualenv and activate it::

    $ python3 -m venv .venv
    $ . .venv/bin/activate

Or on Windows cmd::

    $ py -3 -m venv .venv
    $ .venv\Scripts\activate.bat

Install Flaskr::

    $ pip install -e .

Or if you are using the main branch, install Flask from source before
installing Flaskr::

    $ pip install -e ../..
    $ pip install -e .


Run
---

.. code-block:: text

    $ flask --app flaskr init-db
    $ flask --app flaskr run --debug

Open http://127.0.0.1:5000 in a browser.


Test
----

::

    $ pip install '.[test]'
    $ pytest

Run with coverage report::

    $ coverage run -m pytest
    $ coverage report
    $ coverage html  # open htmlcov/index.html in a browser



Docker Setup
------------

1. Build the Docker image:

   .. code-block:: bash

      docker build -t flask-application:latest .

2. Run the container:

   .. code-block:: bash

      docker run --rm -d -p 5000:5000 flask-application:latest

3. Verify the application in the browser at:

   http://localhost:5000

Jenkins Setup on EC2 (Ubuntu)
-----------------------------

1. **Launch a `t3.large` EC2 instance** with Ubuntu.

2. **Update the system and install Java:**

   .. code-block:: bash

      sudo apt update
      sudo apt install -y openjdk-17-jdk

3. **Add the Jenkins key and install Jenkins:**

   .. code-block:: bash

      curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
        /usr/share/keyrings/jenkins-keyring.asc > /dev/null

      echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
        https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
        /etc/apt/sources.list.d/jenkins.list > /dev/null

      sudo apt update
      sudo apt install -y jenkins

4. **Start Jenkins and check status:**

   .. code-block:: bash

      sudo systemctl start jenkins
      sudo systemctl enable jenkins
      sudo systemctl status jenkins

5. **Allow Jenkins port (8080) in EC2 Security Group**:

   - Go to EC2 → Security Groups → Inbound Rules → Add Rule:
     - Port: 8080
     - Source: Anywhere (0.0.0.0/0) or your IP
     - Protocol: TCP

6. **Access Jenkins:**

   Visit: ``http://<your-ec2-public-dns>:8080``

7. **Unlock Jenkins:**

   .. code-block:: bash

      sudo cat /var/lib/jenkins/secrets/initialAdminPassword

   Copy this password and paste it into the Jenkins UI to continue.

8. **Create Admin User** and proceed.

Install Required Jenkins Plugins
--------------------------------

Install the following plugins via: ``Manage Jenkins → Plugins``

- Pipeline
- Git
- GitHub Integration Plugin
- Docker Pipeline
- Python
- Shining Panda
- Email Extension Plugin
- AnsiColor (optional)

Install Docker and Python on Jenkins EC2
----------------------------------------

1. **Install Docker:**

   .. code-block:: bash

      sudo apt install -y docker.io
      sudo systemctl start docker
      sudo systemctl enable docker

2. **Add Jenkins user to Docker group:**

   .. code-block:: bash

      sudo usermod -aG docker jenkins
      sudo systemctl restart jenkins

3. **Install Python venv package:**

   .. code-block:: bash

      sudo apt install -y python3.12-venv

Jenkins Project Setup
---------------------

1. Go to Jenkins Dashboard → New Item → **Flask-application-CICD** → Select **Pipeline**

2. In Pipeline Configuration:

   - Select **Pipeline script from SCM**
   - SCM: **Git**
   - Provide your GitHub repository URL
   - Jenkinsfile path: ``Jenkinsfile`` (if in root)

3. **Add Credentials (2 total)**:

   Navigate to: ``Manage Jenkins → Credentials → (Global)``

   - **DockerHub Credentials**:
     - ID: `dockerhub`
     - Username: Your DockerHub username
     - Password: Your DockerHub password

   - **Email Notification Credentials**:
     - ID: `email`
     - Username: Your email (e.g., yourname@gmail.com)
     - Password: Your app password (not your main email password)

4. **Configure Email Notification:**

   Go to: ``Manage Jenkins → Configure System → Email Notification``

   - SMTP server: ``smtp.gmail.com``
   - Port: ``587``
   - Use TLS: ✅
   - Default user e-mail suffix: ``@gmail.com``
   - Credentials: Use the `email` credentials
   - Test configuration: Enter your email and test sending a mail

Build and Test Pipeline
-----------------------

1. Click **Build Now** in Jenkins to run the pipeline.

2. If you encounter errors:
   - Read the error messages carefully
   - Search solutions online or ask ChatGPT
   - Modify Jenkinsfile or configuration as needed

3. Once the pipeline is successful, you will:
   - Build and test your app
   - Lint with flake8
   - Build and push Docker image to DockerHub
   - Send email notification
   - Deploy application locally or to a server

Final Notes
-----------

- Be patient: Jenkins pipeline setup can be error-prone
- Use logs and error messages to guide debugging
- You can find the working ``Jenkinsfile`` in the root directory of this repo




