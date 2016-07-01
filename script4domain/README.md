# tv - script4domain - Ricky (Ming Liu)
The scripts I used to add domain and the site,server,app in it is attached. The step to run it:
1. Unzip the fold and copy it in Truview.
2. Go into the folder, run command:
sudo bash addDomain.sh
it will create domain from id 16 to 316.  (id 10-16 is occupied when I run it.)
3. Run command:
sudo bash addSite.sh
it will create 10000 sites with 3 subnet and 2 interfaces   evenly distributed in domain id 16 to 316.
The interfaces in the script not exit in 54 anymore, and I don’t have authority to log on to get the latest interface information (like id). So the interface won’t be added if the script is run now.
4. Run command:
sudo bash addServerDomain
sudo bash addServerDomain
it will add number of custom app and servers evenly distributed in domain id 16 to 316