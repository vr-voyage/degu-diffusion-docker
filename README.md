Degu Diffusion Docker files
---------------------------

The Dockerfile and `docker-compose` setup used to setup
[**DeguDiffusion**](https://github.com/vr-voyage/degu-diffusion) quickly.  
Degu Diffusion is Discord bot you can run on your machine, to provide
StableDiffusion generation capabilities to Discord users.

Check the main project for more information.

Running the bot with Docker-compose
-----------------------------------

Setup an `.env` file with a `DISCORD_TOKEN` and `HUGGINGFACES_TOKEN`.  
Check the `.env.sample` for more information.

Then run `docker-compose up` and wait until you see a message stating :
`StableDiffusion ready to go`.

Getting these tokens
--------------------

Check the [README.md of DeguDiffusion](https://github.com/vr-voyage/degu-diffusion).
