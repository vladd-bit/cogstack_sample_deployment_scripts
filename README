Don't forget to execute chmod -R u+x ./path_to_this_folders_scripts*.sh otherwise you won't be executing much...

Quickstart steps:


wget https://github.com/vladd-bit/cogstack_sample_deployment_scripts/archive/master.zip 

mv ./master.zip ./cogstack_sample_deployment_scripts.zip
unzip ./cogstack_sample_deployment_scripts.zip 
mv ./cogstack_sample_deployment_scripts-master ./etc/cogstack_deployment

find /etc/cogstack_deployment/cogstack_pipeline -name "*.sh" -execdir chmod u+x {} +
find /etc/cogstack_deployment/utils -name "*.sh" -execdir chmod u+x {} +

chmod -R 755 /etc/cogstack_deployment
chown -R root:root /etc/cogstack_deployment


The ``` db_samples.sql.gz ``` belongs to example9.








## Jupyter-hub configuration

The password is set in ./cogstack_pipeline/jupyter-hub/config/jupyter_notebook_config.py 

```
c.NotebookApp.password = u'sha1:90559713cfc9:c4d986a5a63c083626ebc1a74cb874d9203c4152' # 'admin'
```

Please check https://jupyter-notebook.readthedocs.io/en/stable/public_server.html#securing-a-notebook-server for additional configs.
