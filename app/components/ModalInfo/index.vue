<template>
	<div class="absolute top-0 left-0 h-screen w-screen bg-black/60">
		<div class="h-full w-full flex flex-col justify-center items-center">
			<div class="border-2 border-white bg-black py-5 px-10 text-white text-center">
				<h1 class="text-6xl mb-5">{{ title }}</h1>
				<div class="mb-10">
					<slot />
				</div>
				<button
					class="text-black bg-white text-xl py-2 px-8 rounded-xs hover:scale-105 transition-all duration-100 disabled:opacity-50 disabled:cursor-not-allowed"
					@click="dismissModal"
				>
					Close
				</button>
			</div>
		</div>
	</div>
</template>

<script setup>
	defineProps({
		title: String,
		content: String,
	});

	const emit = defineEmits(["dismiss"]);

	const dismissModal = () => {
		emit("dismiss");
	};
</script>
