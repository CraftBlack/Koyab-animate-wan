# Tahap 1: Gunakan base image resmi NVIDIA CUDA yang sudah memiliki Ubuntu
# Versi CUDA 12.4.1 adalah yang stabil dan kompatibel dengan PyTorch cu128
FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

# Set agar frontend tidak interaktif (menghindari prompt saat instalasi)
ENV DEBIAN_FRONTEND=noninteractive

# Install dependensi dasar: git untuk cloning, dan wget + bzip2 untuk instalasi Miniconda
RUN apt-get update && \
    apt-get install -y git wget bzip2 && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda (versi Conda yang lebih ringan)
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh
ENV PATH="/opt/conda/bin:${PATH}"

# =================================================================================
# --- FIX UNTUK ERROR ToS ---
# Tambahkan baris ini untuk menyetujui Terms of Service Anaconda secara otomatis.
# `auto_update_conda false` adalah best practice agar build lebih cepat & stabil.
RUN conda config --set auto_update_conda false && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
# =================================================================================

# Mengatur direktori kerja menjadi /Wan2GP
WORKDIR /Wan2GP

# --- Mulai dari sini, alur mengikuti skrip Anda ---

# 1. Clone repository langsung ke dalam direktori kerja saat ini (/Wan2GP)
RUN git clone https://github.com/deepbeepmeep/Wan2GP.git .

# 2. Buat environment Conda. Ini sekarang akan berjalan dengan sukses.
RUN conda create -n wan2gp python=3.10.9 -y

# 3. Aktifkan environment Conda untuk semua perintah selanjutnya
SHELL ["conda", "run", "-n", "wan2gp", "/bin/bash", "-c"]

# 4. Install PyTorch dan library dari requirements.txt.
RUN pip install torch==2.7.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/test/cu128 && \
    pip install -r requirements.txt

# 5. Tentukan perintah default yang akan dijalankan saat container dimulai.
CMD ["python", "wgp.py"]
