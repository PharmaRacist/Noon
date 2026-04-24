import argparse
import json
import random
import sys

from ytmusicapi import YTMusic


def extract_thumbnail(item):
    thumbs = item.get("thumbnails")
    if isinstance(thumbs, list) and thumbs:
        url = thumbs[-1].get("url", "")
        if url:
            return url

    thumb = item.get("thumbnail")
    if isinstance(thumb, dict):
        nested = thumb.get("thumbnails", [])
        if nested:
            url = nested[-1].get("url", "")
            if url:
                return url

    video_id = item.get("videoId")
    if video_id:
        return f"https://i.ytimg.com/vi/{video_id}/sddefault.jpg"
    return ""


def load_library(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def build_local_tracks(library):
    return {
        f"{item.get('artist', '')} - {item.get('title', '')}".strip().lower()
        for item in library.values()
    }


def fetch_related(yt, seed, limit):
    results = []
    search = yt.search(seed, filter="songs")
    if not search:
        return results
    video_id = search[0].get("videoId")
    if not video_id:
        return results
    playlist = yt.get_watch_playlist(videoId=video_id, limit=limit)
    return playlist.get("tracks", [])


def build_recommendation(item):
    title = item.get("title", "Unknown")
    video_id = item.get("videoId")
    artists = item.get("artists") or []
    artist = artists[0].get("name", "Unknown") if artists else "Unknown"
    url = f"https://music.youtube.com/watch?v={video_id}" if video_id else ""
    thumbnail = extract_thumbnail(item)
    return title, artist, video_id, url, thumbnail


def generate_recommendations(library_path, limit):
    library = load_library(library_path)
    local_tracks = build_local_tracks(library)
    seen = set(local_tracks)

    yt = YTMusic()
    track_list = list(local_tracks)
    num_seeds = max(3, limit // 4)
    seeds = random.sample(track_list, min(len(track_list), num_seeds))

    recommendations = []

    for seed in seeds:
        if len(recommendations) >= limit:
            break
        try:
            tracks = fetch_related(yt, seed, limit=15)
            for item in tracks:
                if len(recommendations) >= limit:
                    break
                title, artist, video_id, url, thumbnail = build_recommendation(item)
                key = f"{artist} - {title}".lower()
                if not video_id or key in seen:
                    continue
                seen.add(key)
                recommendations.append(
                    {
                        "title": title,
                        "artist": artist,
                        "url": url,
                        "thumbnail": thumbnail,
                        "via": seed,
                    }
                )
        except Exception:
            continue

    random.shuffle(recommendations)
    return recommendations[:limit]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("file")
    parser.add_argument("--limit", type=int, default=20)
    args = parser.parse_args()

    try:
        results = generate_recommendations(args.file, args.limit)
        print(json.dumps(results, indent=2))
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
