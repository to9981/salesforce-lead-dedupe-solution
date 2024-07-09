
# Salesforce Lead Dedupe Solution

## Overview
Automate the detection and merging of duplicate lead records in Salesforce with this solution that uses Apex triggers, batch processes, and customizable matching logic.

## Features
- **Automatic Detection**: Identifies duplicates through configurable matching rules.
- **Efficient Merging**: Utilizes batch processing for performance optimization.
- **Stub API Testing Framework**: Ensures reliable and isolated testing of duplicate management logic.

## Key Components
- `LeadAfterInsert.trigger` - Trigger for detecting insert operations.
- `LeadDuplicateEnqueue.cls` - Queueable Apex class to handle operations asynchronously.
- `LeadDuplicateBatch.cls` - Batch Apex class for processing large sets of duplicates.
- `LeadDuplicateHandler.cls` - Core logic for detecting and merging duplicates.
- **Stub API Testing Framework**:
  - `MockUtil.cls` - Utility class for creating mock instances.
  - `MockProvider.cls` - Custom stub provider to define mock behavior.
  - `LeadDuplicateHandlerTest.cls` - Test class demonstrating the usage of stubs for isolated testing.

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/to9981/salesforce-lead-dedupe-solution.git
