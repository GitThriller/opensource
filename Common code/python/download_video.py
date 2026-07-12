import os
import requests
import getpass
import yt_dlp

def download_file(url: str, output_path: str = None, chunk_size: int = 1024 * 1024):
    """
    Download a file from a direct URL (e.g. .mp4, .webm) with streaming.
    """
    if output_path is None:
        filename = url.split("?")[0].split("/")[-1] or "video.mp4"
        output_path = os.path.join(os.getcwd(), filename)

    headers = {
        # Some sites require a user-agent
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    }

    # Prompt for username and password if required
    username = input("Enter username: ")
    password = getpass.getpass("Enter password: ")

    with requests.get(url, headers=headers, auth=(username, password), stream=True) as r:
        r.raise_for_status()
        total = int(r.headers.get("Content-Length", 0))
        downloaded = 0

        print(f"Downloading to: {output_path}")
        with open(output_path, "wb") as f:
            for chunk in r.iter_content(chunk_size=chunk_size):
                if not chunk:
                    continue
                f.write(chunk)
                downloaded += len(chunk)
                if total:
                    done = int(50 * downloaded / total)
                    print("\r[{}{}] {:.1f}%".format(
                        "#" * done, "." * (50 - done), downloaded * 100 / total
                    ), end="")
        print("\nDownload complete!")

    return output_path

def download_video_with_yt_dlp(url: str, output_path: str = None, cookies_file: str = "cookies.txt"):
    """
    Download a video using yt-dlp for streaming links with cookies.
    """
    if not os.path.exists(cookies_file):
        raise FileNotFoundError(f"Cookies file not found: {cookies_file}")

    print(f"Using cookies file: {cookies_file}")

    ydl_opts = {
        'outtmpl': output_path or '%(title)s.%(ext)s',
        'format': 'best',  # Download the best available quality
        'cookies': cookies_file,  # Use cookies for authentication
    }

    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        print(f"Downloading video from: {url}")
        ydl.download([url])


if __name__ == "__main__":
    video_url = "https://smsbgs-my.sharepoint.com/personal/patogiannisa_smbg_vic_edu_au/_layouts/15/stream.aspx?id=%2Fpersonal%2Fpatogiannisa%5Fsmbg%5Fvic%5Fedu%5Fau%2FDocuments%2FDocuments%2FWallaby%20Concert%202025%2F19%2D11%20Wallabies%20Christmas%20Show%2D001%2Emp4&referrer=StreamWebApp%2EWeb&referrerScenario=AddressBarCopied%2Eview%2E8f63b4c0%2Df862%2D4918%2D8534%2D9353bf4ccd88"  # <- replace with real direct URL
    cookies_path = "cookies.txt"  # Path to your exported cookies file

    try:
        download_video_with_yt_dlp(video_url, cookies_file=cookies_path)
    except FileNotFoundError as e:
        print(e)
    except Exception as e:
        print(f"An error occurred: {e}")
