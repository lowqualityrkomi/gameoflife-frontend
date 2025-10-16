<template>
	<div class="h-screen w-full relative">
		<div class="h-full flex flex-col justify-center items-center gap-10">
			<h1 class="text-white text-9xl">Game of life</h1>
			<NuxtLink
				to="/game"
				class="py-2 px-8 rounded-xs bg-white text-black text-xl hover:scale-105 transition-all duration-100"
			>
				Start
			</NuxtLink>
		</div>

		<div class="absolute w-full bottom-3 flex flex-row items-center justify-center gap-5 text-white">
			<a href="https://github.com/lowqualityrkomi/gameoflife-frontend">Game of Life - Backend</a>
			<a href="https://github.com/lowqualityrkomi/gameoflife-backend">Game of Life - Frontend</a>
		</div>
	</div>
</template>

<script setup></script>
