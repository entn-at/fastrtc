# Upload a single demo space
default:
    @just --list

upload path:
    python upload_space.py demo/{{path}}

# Upload all demo spaces
upload-all:
    python upload_space.py demo --all

# Run a demo with uvicorn
run name:
    uvicorn demo.{{name}}.app:app --port 8000

# Run the gradio ui for a demo
gradio name:
    MODE=UI python demo/{{name}}/app.py

# Run a demo with phone mode
phone name:
    MODE=PHONE python demo/{{name}}/app.py

call name:
    MODE=PHONE python demo/{{name}}/app.py

# Upload the latest wheel file to PyPI using twine
publish:
    #!/usr/bin/env python
    import glob
    import os
    from pathlib import Path
    
    # Find all wheel files in dist directory
    wheels = glob.glob('dist/*.whl')
    if not wheels:
        print("No wheel files found in dist directory")
        exit(1)
    
    # Sort by creation time to get the latest
    latest_wheel = max(wheels, key=os.path.getctime)
    print(f"Uploading {latest_wheel}")
    os.system(f"twine upload {latest_wheel}")

# Upload the latest wheel to HF space with a random ID
publish-dev:
    #!/usr/bin/env python
    import glob
    import os
    import uuid
    import subprocess
    
    # Find all wheel files in dist directory
    wheels = glob.glob('dist/*.whl')
    if not wheels:
        print("No wheel files found in dist directory")
        exit(1)
    
    # Sort by creation time to get the latest
    latest_wheel = max(wheels, key=os.path.getctime)
    wheel_name = os.path.basename(latest_wheel)
    
    # Generate random ID
    random_id = str(uuid.uuid4())[:8]
    
    # Define the HF path
    hf_space = "freddyaboulton/bucket"
    hf_path = f"wheels/fastrtc/{random_id}/"
    
    # Upload to Hugging Face space
    cmd = f"huggingface-cli upload {hf_space} {latest_wheel} {hf_path}{wheel_name} --repo-type dataset"
    subprocess.run(cmd, shell=True, check=True)
    
    # Print the URL
    print(f"Wheel uploaded successfully!")
    print(f"URL: https://huggingface.co/datasets/{hf_space}/resolve/main/{hf_path}{wheel_name}")

# Build the package
build:
    gradio cc build --no-generate-docs

# Format the code
format:
    ruff format .
    ruff check --fix .
    ruff check --select I --fix .
    cd frontend && npx prettier --write . && cd ..

docs:
    mkdocs serve -a localhost:8081