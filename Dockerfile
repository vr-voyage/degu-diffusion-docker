
FROM python:3.10

RUN git clone --depth 1 https://github.com/vr-voyage/degu-diffusion /app
WORKDIR /app

# Each package is installed in a separate step in order
# to resume more easily when errors occur during the
# installation.
# Remember that some packages can easily take a few minutes to
# install.
RUN pip3 install 'numpy>=1.23.2'
RUN pip3 install --extra-index-url https://download.pytorch.org/whl/cu113 'torch>=1.12.0' torchvision torchaudio
RUN pip3 install 'diffusers>=0.4.0'
RUN pip3 install transformers
RUN pip3 install scipy
RUN pip3 install ftfy
RUN pip3 install background
RUN pip3 install discord.py
RUN pip3 install python-dotenv

ENTRYPOINT ["python3", "degu_diffusion_v0.py"]
