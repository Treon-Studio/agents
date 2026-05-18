export interface Skill {
	id: string;
	title: string;
	description: string;
	category: "design" | "engineering" | "data" | "writing" | "product" | "business" | "education" | "science" | "ai" | "community";
	tags: string[];
	author: string;
	authorUrl?: string;
	skillUrl: string;
	featured: boolean;
	installs: number;
	stars: number;
	publishDate: string;
	createdAt: string;
	updatedAt: string;
}

export type SkillCategory = Skill["category"];

export interface CategoryMeta {
	slug: SkillCategory;
	count: number;
}

export interface ApiResponse<T> {
	success: boolean;
	data: T;
	meta?: {
		page: number;
		limit: number;
		total: number;
		lastPage: number;
	};
	error?: string;
}

const API_BASE = "http://localhost:8787/api/v1";

async function fetchApi<T>(endpoint: string): Promise<T> {
	const res = await fetch(`${API_BASE}${endpoint}`);
	if (!res.ok) throw new Error(`API error: ${res.status}`);
	return res.json();
}

export async function getAllSkills(params?: { category?: string; search?: string; page?: number }) {
	const query = new URLSearchParams();
	if (params?.category) query.set("category", params.category);
	if (params?.search) query.set("search", params.search);
	if (params?.page) query.set("page", params.page.toString());

	const endpoint = `/skills${query.toString() ? `?${query.toString()}` : ""}`;
	const res = await fetchApi<ApiResponse<Skill[]>>(endpoint);
	return res;
}

export async function getSkillById(id: string): Promise<Skill | null> {
	try {
		const res = await fetchApi<ApiResponse<Skill>>(`/skills/${id}`);
		return res.data;
	} catch {
		return null;
	}
}

export async function getFeaturedSkills(): Promise<Skill[]> {
	const res = await fetchApi<ApiResponse<Skill[]>>("/skills/featured/list");
	return res.data;
}

export async function getAllCategories(): Promise<SkillCategory[]> {
	return ["design", "engineering", "data", "writing", "product", "business", "education", "science", "ai", "community"];
}

export async function getCategoryMeta(): Promise<CategoryMeta[]> {
	const res = await fetchApi<ApiResponse<{ slug: string; count: number }[]>>("/categories");
	return res.data.map((c) => ({ slug: c.slug as SkillCategory, count: c.count }));
}

export async function getRelatedSkills(currentSkillId: string, category: SkillCategory, limit = 3): Promise<Skill[]> {
	const skills = await getAllSkills({ category, page: 1 });
	return skills.data.filter((s) => s.id !== currentSkillId).slice(0, limit);
}

export function paginateSkills<T>(items: T[], page = 1, perPage = 12) {
	const total = items.length;
	const lastPage = Math.ceil(total / perPage);
	const offset = (page - 1) * perPage;
	const paginatedItems = items.slice(offset, offset + perPage);

	return {
		total,
		lastPage,
		currentPage: page,
		perPage,
		items: paginatedItems,
	};
}

export function formatInstalls(count: number): string {
	if (count >= 1000000) return (count / 1000000).toFixed(1).replace(/\.0$/, "") + "M";
	if (count >= 1000) return (count / 1000).toFixed(1).replace(/\.0$/, "") + "K";
	return count.toString();
}