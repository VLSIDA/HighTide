#!/usr/bin/env python3

import json
import os
import sys
from pathlib import Path
from datetime import datetime
import argparse


def extract_key_metrics(report_path):
    """Extract key metrics from a report json file."""
    try:
        with open(report_path, 'r') as f:
            data = json.load(f)

        metrics = {
            'design_name': '',
            'platform': '',
            'total_area': data.get('finish__design__core__area', 'N/A'),
            'utilization': f"{data.get('finish__design__instance__utilization', 0) * 100:.1f}%" if data.get('finish__design__instance__utilization') else 'N/A',
            'instance_count': data.get('finish__design__instance__count', 'N/A'),
            'setup_tns': data.get('finish__timing__setup__tns', 'N/A'),
            'setup_wns': data.get('finish__timing__setup__ws', 'N/A'),
            'hold_tns': data.get('finish__timing__hold__tns', 'N/A'),
            'hold_wns': data.get('finish__timing__hold__ws', 'N/A'),
            'total_power': f"{data.get('finish__power__total', 0) * 1000:.3f} mW" if data.get('finish__power__total') else 'N/A',
            'clock_skew': data.get('finish__clock__skew__setup', 'N/A'),
            'warnings': data.get('finish__flow__warnings__count', 'N/A'),
            'errors': data.get('finish__flow__errors__count', 'N/A'),
            'status': 'Pass' if data.get('finish__flow__errors__count', 1) == 0 else 'Fail'
        }

        return metrics
    except (FileNotFoundError, json.JSONDecodeError, KeyError) as e:
        print(f"Error reading {report_path}: {e}")
        return None


def find_report_files(base_dir):
    """Find all 6_report.json files in the results directory structure."""
    report_files = []
    base_path = Path(base_dir)

    for report_file in base_path.rglob("logs/**/6_report.json"):
        parts = report_file.parts
        if len(parts) >= 4:
            # Extract platform and design from path
            logs_idx = next(i for i, part in enumerate(
                parts) if part == 'logs')
            if logs_idx + 3 < len(parts):
                platform = parts[logs_idx + 1]
                design = parts[logs_idx + 2]
                report_files.append({
                    'path': report_file,
                    'platform': platform,
                    'design': design
                })

    return report_files


def generate_markdown_table(results, github_repo=None, github_run_id=None, artifacts_file=None):
    """Generate a markdown table from the results."""
    if not results:
        return "No results found.\n"

    # Load artifact information if available
    artifact_map = {}
    if artifacts_file and os.path.exists(artifacts_file):
        try:
            with open(artifacts_file, 'r') as f:
                artifacts_data = json.load(f)
                # Create mapping of artifact name to ID
                for artifact in artifacts_data.get('artifacts', []):
                    artifact_map[artifact['name']] = artifact['id']
        except Exception as e:
            print(f"Warning: Could not load artifacts file: {e}")

    # Table header - add Image column if GitHub info is provided
    if github_repo and github_run_id:
        table = """
## OpenROAD Flow Results

Last updated: {}

| Design | Platform | Status | Area (μm²) | Utilization | Instances | Setup TNS | Setup WNS | Hold TNS | Hold WNS | Power | Clock Skew | Warnings | Errors | Image |
|--------|----------|--------|------------|-------------|-----------|-----------|-----------|----------|----------|-------|------------|----------|--------|-------|
""".format(datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC"))
    else:
        table = """
## OpenROAD Flow Results

Last updated: {}

| Design | Platform | Status | Area (μm²) | Utilization | Instances | Setup TNS | Setup WNS | Hold TNS | Hold WNS | Power | Clock Skew | Warnings | Errors |
|--------|----------|--------|------------|-------------|-----------|-----------|-----------|----------|----------|-------|------------|----------|--------|
""".format(datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC"))

    # Sort results by platform, then design name
    sorted_results = sorted(results, key=lambda x: (
        x['platform'], x['design_name']))

    # Table rows
    for result in sorted_results:
        if github_repo and github_run_id:
            # Generate artifact name for this design's image (matching workflow naming)
            sanitized_name = f"designs-{result['platform']}-{result['design_name']}"
            artifact_name = f"design-image-{sanitized_name}"
            
            # Try to get the specific artifact ID for direct download
            if artifact_name in artifact_map:
                artifact_id = artifact_map[artifact_name]
                artifact_url = f"https://github.com/{github_repo}/actions/runs/{github_run_id}/artifacts/{artifact_id}"
                image_link = f"[Download Image]({artifact_url})"
            else:
                # Fallback to run page if artifact ID not found
                artifact_url = f"https://github.com/{github_repo}/actions/runs/{github_run_id}"
                image_link = f"[View Run]({artifact_url})"

            table += f"| {result['design_name']} | {result['platform']} | {result['status']} | {result['total_area']} | {result['utilization']} | {result['instance_count']} | {result['setup_tns']} | {result['setup_wns']} | {result['hold_tns']} | {result['hold_wns']} | {result['total_power']} | {result['clock_skew']} | {result['warnings']} | {result['errors']} | {image_link} |\n"
        else:
            table += f"| {result['design_name']} | {result['platform']} | {result['status']} | {result['total_area']} | {result['utilization']} | {result['instance_count']} | {result['setup_tns']} | {result['setup_wns']} | {result['hold_tns']} | {result['hold_wns']} | {result['total_power']} | {result['clock_skew']} | {result['warnings']} | {result['errors']} |\n"

    table += "\n"
    return table


def update_readme(readme_path, results_table):
    """Update the README.md file with the results table."""
    try:
        with open(readme_path, 'r') as f:
            content = f.read()

        # Find the marker or add one
        start_marker = "<!-- ORFS_RESULTS_START -->"
        end_marker = "<!-- ORFS_RESULTS_END -->"

        if start_marker in content and end_marker in content:
            # Replace existing table
            start_idx = content.find(start_marker)
            end_idx = content.find(end_marker) + len(end_marker)
            new_content = (content[:start_idx] +
                           start_marker + "\n" +
                           results_table +
                           end_marker +
                           content[end_idx:])
        else:
            # Add table at the end
            new_content = content + "\n" + start_marker + \
                "\n" + results_table + end_marker + "\n"

        with open(readme_path, 'w') as f:
            f.write(new_content)

        print(f"Updated {readme_path} with results table")

    except Exception as e:
        print(f"Error updating README: {e}")


def main():
    parser = argparse.ArgumentParser(
        description='Extract OpenROAD metrics and update README')
    parser.add_argument('--base-dir', default='.',
                        help='Base directory to search for results (default: current directory)')
    parser.add_argument('--readme', default='README.md',
                        help='Path to README.md file to update (default: README.md)')
    parser.add_argument('--output', default=None,
                        help='Output file for results table (default: update README)')
    parser.add_argument('--github-repo', default=None,
                        help='GitHub repository (owner/repo) for artifact links')
    parser.add_argument('--github-run-id', default=None,
                        help='GitHub Actions run ID for artifact links')
    parser.add_argument('--artifacts-file', default=None,
                        help='JSON file containing GitHub artifacts information')

    args = parser.parse_args()

    # Find all report files
    report_files = find_report_files(args.base_dir)
    print(f"Found {len(report_files)} report files")

    # Extract metrics from each report
    results = []
    for report_info in report_files:
        print(
            f"Processing {report_info['platform']}/{report_info['design']}...")
        metrics = extract_key_metrics(report_info['path'])
        if metrics:
            metrics['design_name'] = report_info['design']
            metrics['platform'] = report_info['platform']
            results.append(metrics)

    # Generate markdown table
    table = generate_markdown_table(results, args.github_repo, args.github_run_id, args.artifacts_file)

    if args.output:
        # Write to specified output file
        with open(args.output, 'w') as f:
            f.write(table)
        print(f"Results written to {args.output}")
    else:
        # Update README
        update_readme(args.readme, table)

    print(f"Processed {len(results)} designs successfully")


if __name__ == "__main__":
    main()
