# DeguDiffusion Docker image

This repository contains the file to build the official Docker image of
my Discord bot software [**DeguDiffusion**](https://github.com/vr-voyage/degu-diffusion),
that allows you to run your own AI images generation bot on Discord
using a local installation of StableDiffusion.

![Screenshot of a bot usage](https://github.com/vr-voyage/degu-diffusion/raw/main/screenshots/GenerateForm-Result.png)

![Screenshot of /degudiffusion form](https://github.com/vr-voyage/degu-diffusion/raw/main/screenshots/Apps-Repeat-Diffusion-Form.png)

The concept behind it is simple :

* You create a bot account, and add its token to the `.env` file as `DISCORD_TOKEN`.
* The software will use the bot account to connect to Discord and register image
  generation commands (`/degudiffusion` notably) on the servers it has been invited
  to.
* Users on the servers use these commands to send image generation requests to your server.
* Your server generate the images, using a local installation of
  [HuggingFaces StableDiffusion](https://huggingface.co/CompVis/stable-diffusion-v1-4),
  and send back the result through Discord.

You can of course run the bot inside Docker, while being connected to
Discord with another account on the same machine.

The software is available under MIT license.

# Example setup

**.env**

```bash
# Make sure your bot has sufficient rights and privileges.
# Write your Discord bot token after the '='. No quotes needed.
DISCORD_TOKEN=

# Make sure you accepted the license on
# https://huggingface.co/CompVis/stable-diffusion-v1-4
# Write your Huggingfaces token after the '='. No quotes needed.
HUGGINGFACES_TOKEN=
```

**docker-compose.yml**

```yaml
version: "3.9"
services:
  degu:
    image: vrvoyage/degudiffusion:1.0
    #build: .
    env_file: .env
    environment:
      - STABLEDIFFUSION_CACHE_DIR=stablediffusion_cache
      - IMAGES_OUTPUT_DIRECTORY=generated # Can be commented if SAVE_IMAGES_TO_DISK is set to false
      # - SAVE_IMAGES_TO_DISK=false # If you uncomment this, you can comment the first volume
      # - STABLEDIFFUSION_MODE=fp16 # If you're low on VRAM
      # - STABLEDIFFUSION_MODEL_NAME=hakurei/waifu-diffusion # If you want to use Waifu Diffusion
    volumes:
      - ./generated:/app/generated # Only required if SAVE_IMAGES_TO_DISK=false isn't set
      - ./cache:/app/stablediffusion_cache # Related to STABLEDIFFUSION_CACHE_DIR
      - ./config:/app/config # Can be mounted in Read-Only if a 'replacers.json' file is already present
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
```

## Running the example setup

```bash
docker-compose up
```

# Requirements

* As you can understand, the server is required to have access to a GPU.  
  The only tested setup is Windows / NVIDIA Graphics Card / CUDA.  
  This setup has not been tested at all with CPU only setup.  
  This setup has not been tested at all with ROCM.

* Ensure that you can use the GPU through Docker.

* A [Discord Bot](https://discord.com/developers/applications) Token.  
  Environment variable : `DISCORD_TOKEN`  
  See below for more information about how to create and register your
  own bot on Discord, and how to retrieve its token.

* A [HuggingFaces Token](https://huggingface.co/settings/tokens).  
  Environment variable : `HUGGINGFACES_TOKEN`  
  This is required to download the weights the first time.  
  Once done, you can set the environment variable
  `STABLEDIFFUSION_LOCAL_ONLY=true` to reuse the local files,
  in which case `HUGGINGFACES_TOKEN` isn't required anymore.

* Accepting the [licence terms of StableDiffusion](https://huggingface.co/CompVis/stable-diffusion-v1-4)  
  The licence is pretty permissive, but to download the weights from
  HuggingFaces, you'll have to click on the accept button on the
  page :  
  https://huggingface.co/CompVis/stable-diffusion-v1-4

* Setup `DISCORD_TOKEN` and `HUGGINGFACES_TOKEN` environment variables.

## Creating a Discord application and a bot account

* Go to the [Discord Developer portal](https://discord.com/developers/applications).
* Create a "New application", by clicking the upper right button near your Profile icon.
* Setup the name then make sure you're currently editing your new application.
* In Bot (Left panel), in "Build-A-Bot", click on "Add Bot" and Confirm.
* While you are on the bot configuration pane, enable :
  * **Message Content Intent**  
  > You can leave other intents disabled.
* On Oauth2 General (Left panel), select :
  * **AUTHORIZATION METHOD**  
  In-app Authorization
  * **SCOPES**
    * `bot`
    * `application.commands`
  * **BOT PERMISSIONS**
    * Read Messages / View Channels
    * Send Messages
    * Create Public Threads
    * Send Messages in Threads
    * Attach Files
 * On OAuth2 URL Generator (Left panel) : 
   * Select the same **SCOPES** (`bot` and `application.commands`) and **PERMISSIONS**.
   * Copy the generated URL at the bottom.
* Enter this URL in your browser to invite the generated bot on one of your servers.  
> You can also send this link to others servers admins who'd like to invite the bot to
> their servers.
* In Bot, again, click on 'Reset Token' and save it as `DISCORD_TOKEN` in the `.env` file.

> If the permissions were wrong :  
>   Set the permissions again on both panels  
>   Open the new URL in your browser and invite the Bot again on the same server.

### Screenshots of the authorizations

#### Oauth2 General

![Screenshot of authorizations checkboxes required in Oauth2 General](https://github.com/vr-voyage/degu-diffusion/raw/main/screenshots/Discord-App-Oauth2-General.png)

#### Bot intentions

![Screenshot of the Bot setup](https://github.com/vr-voyage/degu-diffusion/raw/main/screenshots/Discord-Bot-Intentions.png)

#### Oauth2 URL Generator

![Screensoht of authorizations checkboxes required in Oauth2 URL Generator](https://github.com/vr-voyage/degu-diffusion/raw/main/screenshots/Discord-App-Oauth2-URL-Generator.png)

#### Discord Bot Token

If you don't know it, click on "Reset Token" in the "Bot" section of your
application.
You can view your application settings on the [Discord Developer Portal](https://discord.com/developers/applications).

![Screenshot of the Reset Token page](https://github.com/vr-voyage/degu-diffusion/raw/main/screenshots/Discord-Bot-Token.png)

# Environment variables

* `IMAGES_OUTPUT_DIRECTORY`  
  Define where you want to store the generated pictures.  
  **Default** : `generated`  
  Spaces are allowed. No need to use quotes.  
  The directory will be created if it doesn't exist.  
  Example : `IMAGES_OUTPUT_DIRECTORY=another folder`  
  > This setting is ignored when `SAVE_IMAGES_TO_DISK` is set to `false`.  
  > In the `docker-compose.yml` sample, this setting is linked
  > to the `./generated` mountpoint.

* `SAVE_IMAGES_TO_DISK`  
  Define whether generated files are saved on the disk or not.  
  **Default** : `true`  
  Example : `SAVE_IMAGES_TO_DISK=false`  
  > This setting is ignored when testing Stable Diffusion alone.

* `STABLEDIFFUSION_MODEL_NAME`  
  Determine the HuggingFaces model used by `StableDiffusionPipeline`.  
  **Default** : `CompVis/stable-diffusion-v1-4`  
  Example : `STABLEDIFFUSION_MODEL_NAME=hakurei/waifu-diffusion`

* `STABLEDIFFUSION_MODE`  
  Allows you to select between different StableDiffusion modes.  
  **Default** : `fp32`  
  Currently only fp16 and fp32 are supported.  
  VRAM usage is lower in fp16, so if you're low on VRAM,
  set this to `fp16`.  
  Example : `STABLEDIFFUSION_MODE=fp16`

* `MAX_IMAGES_PER_JOB`  
  Maximum number of images to output per job request.  
  **Default** : `64`  
  That means that the **NUMBER OF IMAGES** typed in `/degudiffusion`
  form will be clamped to that maximum value.  
  Example : `MAX_IMAGES_PER_JOB=8`

* `MAX_INFERENCES_PER_IMAGE`  
  Maximum number of inferences steps per image.  
  **Default** : `120`  
  This clamps the **INFERENCES** number typed in `/degudiffusion`
  form to that maximum value.  
  Example : `MAX_INFERENCES_PER_IMAGE=30`

* `MAX_GUIDANCE_SCALE_PER_IMAGE`  
  Maximal guidance scale allowed.  
  **Default** : `20`  
  This clamps the **GUIDANCE SCALE** number typed in `/degudiffusion`
  form will be clamped to that maximum value.  
  Example : `MAX_GUIDANCE_SCALE_PER_IMAGE=7.5`

* `IMAGES_WIDTH` and `IMAGES_HEIGHT`  
  The width and height of generated images.  
  **Default** : `512`  
  Be ***EXTREMELY*** careful with this one, VRAM usage grows dramatically
  when using higher values.  
  I highly recommend to switch to fp16 when using more than 512x512.  
  Going below 512 in any direction will generally lead to garbage results.  
  Example :  
  `IMAGES_WIDTH=768`  
  `IMAGES_HEIGHT=768`

* `MAX_IMAGES_BEFORE_THREAD`  
  The number of images after which the bot will automatically create a thread.  
  **Default** : `2`  
  That means that if you set it to 5 :  
  When requesting up to 5 images per job, the bot will output everything
  on the channel from where the job request was done.  
  When requesting 6 images or more, the bot will create a thread and
  send the results inside this thread.  
  Example : `MAX_IMAGES_BEFORE_THREAD=5`

* `COMPACT_RESPONSES`  
  When set to `True` or `true`, the job response will only include the pictures,
  without any further details (like the Seed, Actual Prompt.).  
  **Default** : `false`  
  Example : `COMPACT_RESPONSES=True`  
  > You can still use "Check Degu PNG Metadata" when using compact responses.

* `DEFAULT_IMAGES_PER_JOB`  
  The default **NUMBER OF IMAGES** used in `/degudiffusion` form.  
  **Default** : `8`  
  Example : `DEFAULT_IMAGES_PER_JOB=3`

* `DEFAULT_PROMPT`  
  The default **PROMPT** used in `/degudiffusion` form.  
  **Default** : `Degu enjoys its morning coffee by {random_artists}, {random_tags}`  
  Example : `DEFAULT_PROMPT=A Nendoroid of a Chipmunk by {random_artists}, {lyuma_cheatcodes}`

* `DEFAULT_SEED`  
  The default **SEED** used in `/degudiffusion` form.  
  **Default** to an empty value.  
  Note that you don't have to type a SEED value, in Degu Diffusion.  
  When no seed is provided, a random seed is generated for you.  
  Example : `DEFAULT_SEED=-1`

* `DEFAULT_INFERENCES_STEPS`  
  The default number of **INFERENCES** used in `/degudiffusion` form.  
  **Default** : `60`  
  Example : `DEFAULT_INFERENCES_STEPS=30`

* `DEFAULT_GUIDANCE_SCALE`  
  The default **GUIDANCE SCALE** used in `/degudiffusion` form.  
  **Default** : `7.5`  
  Example : `DEFAULT_GUIDANCE_SCALE=15`

* `SEED_MINUS_ONE_IS_RANDOM`  
  Determine if -1 should be interpreted as a random seed or an actual seed value.  
  **Default** : True  
  By default, now, `-1` is treated as a random value, since many users
  are used to type `-1` to get a random seed.  
  Note that you don't have to type a SEED value, in Degu Diffusion.  
  When no seed is provided, a random seed is generated for you.  
  Example : `SEED_MINUS_ONE_IS_RANDOM=false`

* `STABLEDIFFUSION_LOCAL_ONLY`  
  Force `StableDiffusionPipeline` to use predownloaded local files only, and avoid
  connecting to the internet.  
  **Default** : `false`  
  Example : `STABLEDIFFUSION_LOCAL_ONLY=true`  
  > When set to true, `HUGGINGFACES_TOKEN` is not required anymore.

* `STABLEDIFFUSION_CACHE_DIR`  
  Determine where `StableDiffusionPipeline` download its files to.  
  **Empty by Default**  
  This is mainly used for Docker setups.  
  When not set, or set to an empty string, `StableDiffusionPipeline` will
  determine where to download its files.  
  Example : `STABLEDIFFUSION_CACHE_DIR=sd_cache`  
  > The directory will be created if it doesn't exist.

* `TORCH_DEVICE`  
  Determine the PyTorch device used. Default to "cuda".  
  **Default** : `cuda`  
  Any value other that `cuda` is untested.  
  Example : `TORCH_DEVICE=rocm`

* `FORM_NUMBER_OF_IMAGES_INPUT_MAX`  
  Maximum number of characters allowed for **NUMBER OF IMAGES** in
  /degudiffusion form.  
  **Default** : `4`  
  Example : `FORM_NUMBER_OF_IMAGES_INPUT_MAX=3`

* `FORM_PROMPT_INPUT_MAX`  
  Maximum number of characters allowed for **PROMPT** in
  /degudiffusion form.  
  **Default** : `500`  
  Example : `FORM_PROMPT_INPUT_MAX=100`  
  > Note that with the default setup, StableDiffusion will
  > parse up to 77 tokens and ignore the rest.  

* `FORM_SEED_INPUT_MAX`  
  Maximum number of characters allowed for **SEED** in
  /degudiffusion form.  
  **Default** : `38`  
  Example : `FORM_SEED_INPUT_MAX=200`

* `FORM_INFERENCES_INPUT_MAX`
  Maximum number of characters allowed for **INFERENCES** in
  /degudiffusion form.  
  **Default** : `3`  
  Example : `FORM_INFERENCES_INPUT_MAX=2`

* `FORM_GUIDANCE_SCALE_INPUT_MAX`  
  Maximum number of characters allowed for GUIDANCE SCALE in
  /degudiffusion form.  
  **Default** : `6`  
  Example : `FORM_GUIDANCE_SCALE_INPUT_MAX=3`  
  > Be careful, conversion from float to string adds at least one decimal.  
  This conversion might lead to errors when using the `DEFAULT_GUIDANCE_SCALE`,
  while preparing the form.  
  For example, if `DEFAULT_GUIDANCE_SCALE=7` then the displayed value
  will be `7.0`, and will take 3 characters.  
  If `FORM_GUIDANCE_SCALE_INPUT_MAX` is set to `2` characters, the form
  will become unuseable.
