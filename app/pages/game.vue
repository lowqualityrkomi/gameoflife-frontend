<template>
	<div class="h-screen w-full relative">
		<div v-if="grid == null" class="h-full flex flex-col justify-center items-center">
			<button class="absolute top-5 right-5 text-white" @click="showModalInfo = !showModalInfo">
				<Icon name="material-symbols:info-outline" size="40" />
			</button>
			<h1 class="text-6xl text-white mb-10">Initialize the game</h1>
			<div class="flex flex-row items-center gap-3 mb-5">
				<div>
					<p class="text-white text-xl">Rows</p>
					<input v-model="rows" class="py-2 px-4 border border-white text-white rounded-xs" />
				</div>
				<div>
					<p class="text-white text-xl">Columns</p>
					<input v-model="columns" class="py-2 px-4 border border-white text-white rounded-xs" />
				</div>
				<div>
					<p class="text-white text-xl">Seed</p>
					<input v-model="seed" class="py-2 px-4 border border-white text-white rounded-xs" />
				</div>
			</div>
			<button
				class="text-black bg-white text-xl py-2 px-8 rounded-xs hover:scale-105 transition-all duration-100 disabled:opacity-50 disabled:cursor-not-allowed"
				:disabled="verifyInitData() || isLoadingGrid"
				@click="initializeGame"
			>
				<Icon name="eos-icons:loading" color="black" v-if="isLoadingGrid" />
				<span>Play</span>
			</button>
		</div>
		<div v-else class="h-full w-full flex flex-col relative">
			<div class="absolute top-5 left-1/2 transform -translate-x-1/2 z-10">
				<div class="flex justify-center items-center gap-3">
					<button
						class="bg-black text-white border-2 border-white py-2 px-4 rounded-xs hover:bg-white hover:text-black hover:border-black transition-all"
						@click="nextMove"
						:disabled="isLoadingNextMove"
					>
						<Icon name="eos-icons:loading" color="black" v-if="isLoadingNextMove" />
						<span>Next move</span>
					</button>
					<button
						class="bg-black text-white border-2 border-white py-2 px-4 rounded-xs hover:bg-white hover:text-black hover:border-black transition-all"
						@click="destoryGame"
					>
						<span>Destroy Game</span>
					</button>
				</div>
			</div>
			<div v-for="(row, i) in grid" :key="i" class="flex flex-1">
				<div
					v-for="(cell, j) in row"
					:key="j"
					:class="`flex-1 transition-colors duration-75 ${cell ? 'bg-white' : 'bg-black'}`"
				></div>
			</div>
		</div>

		<ModalInfo v-if="showModalInfo" title="Game of life" @dismiss="showModalInfo = !showModalInfo">
			<h3>Problem Description</h3>
			<p>
				This Kata is about calculating the next generation of Conway’s game of life, given any starting
				position. See
				<a
					class="font-bold underline"
					href="https://en.wikipedia.org/wiki/Conway's_Game_of_Life"
					target="_blank"
				>
					Conway's Game of Life
				</a>
				for background.
			</p>
			<p>
				You start with a two dimensional grid of cells, where each cell is either alive or dead. The grid is
				finite, and no life can exist off the edges. When calculating the next generation of the grid, follow
				these rules:
			</p>
			<ol>
				<li>Any live cell with fewer than two live neighbours dies, as if caused by underpopulation.</li>
				<li>Any live cell with more than three live neighbours dies, as if by overcrowding.</li>
				<li>Any live cell with two or three live neighbours lives on to the next generation.</li>
				<li>Any dead cell with exactly three live neighbours becomes a live cell.</li>
			</ol>
			<p>
				You should write a program that starts with a random grid of cells, and will output a similar grid
				showing the next generation.
			</p>
		</ModalInfo>
	</div>
</template>

<script setup lang="ts">
	// Types
	interface GameStatusResponse {
		gameId: string;
		rows: number;
		columns: number;
		grid: boolean[][];
	}

	interface CreateGameRequest {
		rows: number;
		columns: number;
		seed: number;
	}

	// State
	const grid = ref<boolean[][] | null>(null);
	const rows = ref<number | undefined>();
	const columns = ref<number | undefined>();
	const seed = ref<number | undefined>();
	const isLoadingGrid = ref<boolean>(false);
	const isLoadingNextMove = ref<boolean>(false);
	const showModalInfo = ref<boolean>(false);
	const gameId = ref<string>("");

	// API Base URL
	const API_BASE_URL = "https://api.gof.lowquality.moe/api";

	// Functions
	const initializeGame = async (): Promise<void> => {
		try {
			const requestBody: CreateGameRequest = {
				rows: rows.value!,
				columns: columns.value!,
				seed: seed.value!,
			};

			isLoadingGrid.value = true;

			const request = await fetch(`${API_BASE_URL}/games/create`, {
				method: "POST",
				headers: {
					"Content-Type": "application/json",
				},
				body: JSON.stringify(requestBody),
			});

			if (request.ok) {
				const response: GameStatusResponse = await request.json();
				grid.value = response.grid;
				gameId.value = response.gameId;
			} else {
				const errorText = await request.text();
				console.error("Failed to create game:", request.statusText, errorText);
			}
		} catch (error) {
			console.error("Error initializing game:", error);
		} finally {
			isLoadingGrid.value = false;
		}
	};

	const nextMove = async () => {
		try {
			isLoadingNextMove.value = true;

			const request = await fetch(`${API_BASE_URL}/games/next-move`, {
				method: "GET",
				headers: {
					"Content-Type": "application/json",
					"x-game-id": gameId.value,
				},
			});

			if (request.ok) {
				const response: GameStatusResponse = await request.json();
				grid.value = response.grid;
				gameId.value = response.gameId;
			}
		} catch (error) {
			console.error("Error asking next move:", error);
		} finally {
			isLoadingNextMove.value = false;
		}
	};

	const destoryGame = async () => {
		try {
			const request = await fetch(`${API_BASE_URL}/games/delete`, {
				method: "DELETE",
				headers: {
					"Content-Type": "application/json",
					"x-game-id": gameId.value,
				},
			});

			grid.value = null;
			rows.value = undefined;
			columns.value = undefined;
			seed.value = undefined;
		} catch (error) {
			console.error("Error removing game:", error);
		}
	};

	const verifyInitData = (): boolean => {
		const dataChecker = (value: number | undefined): boolean => !value || !Number(value) || value <= 0;

		return dataChecker(rows.value) || dataChecker(columns.value) || dataChecker(seed.value);
	};

	onBeforeUnmount(async () => {
		await destoryGame();
	});
</script>
