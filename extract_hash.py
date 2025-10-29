import sys
import tomllib


def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <file> <package-name>")
        sys.exit(1)

    file_path, package_name = sys.argv[1], sys.argv[2]

    with open(file_path, "rb") as f:
        data = tomllib.load(f)

    try:
        hash_value = next(
            p["sdist"]["hash"] for p in data["package"] if p["name"] == package_name
        )
    except StopIteration:
        print(f"Package '{package_name}' not found.")
        sys.exit(1)

    print(hash_value)


if __name__ == "__main__":
    main()
