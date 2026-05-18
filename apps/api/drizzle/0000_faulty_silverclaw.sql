CREATE TABLE `skills` (
	`id` text PRIMARY KEY NOT NULL,
	`title` text NOT NULL,
	`description` text NOT NULL,
	`category` text NOT NULL,
	`tags` text DEFAULT '[]',
	`author` text NOT NULL,
	`author_url` text,
	`skill_url` text NOT NULL,
	`featured` integer DEFAULT false,
	`installs` integer DEFAULT 0,
	`stars` integer DEFAULT 0,
	`publish_date` text NOT NULL,
	`created_at` text NOT NULL,
	`updated_at` text NOT NULL
);
